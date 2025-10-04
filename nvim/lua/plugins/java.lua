-- Função utilitária para carregar .env com parsing mais robusto
local function load_env_file(path)
  local env = {}
  local f = io.open(path, "r")
  if not f then
    vim.notify("⚠️  Arquivo .env não encontrado: " .. path, vim.log.levels.WARN)
    return env
  end

  local line_count = 0
  local loaded_count = 0

  for line in f:lines() do
    line_count = line_count + 1

    -- Remover espaços em branco no início e fim
    line = line:gsub("^%s+", ""):gsub("%s+$", "")

    -- Pular linhas vazias e comentários
    if line == "" or line:match("^#") then
      goto continue
    end

    -- Procurar por padrão key=value mais flexível
    local key, value = line:match("^([%w_%-%.]+)%s*=%s*(.*)$")

    if key and value then
      -- Remover aspas se existirem (simples ou duplas)
      if value:match("^['\"].*['\"]$") then
        value = value:sub(2, -2)
      end

      -- Remover comentários inline (depois de #)
      local comment_pos = value:find("#")
      if comment_pos then
        value = value:sub(1, comment_pos - 1):gsub("%s+$", "")
      end

      env[key] = value
      loaded_count = loaded_count + 1
    else
      vim.notify("⚠️  Linha inválida no .env (linha " .. line_count .. "): " .. line, vim.log.levels.WARN)
    end

    ::continue::
  end

  f:close()

  vim.notify(
    "✅ .env carregado: " .. loaded_count .. " variáveis de " .. line_count .. " linhas",
    vim.log.levels.INFO
  )

  -- Debug: mostrar algumas variáveis carregadas
  local debug_vars = {}
  local count = 0
  for k, v in pairs(env) do
    if count < 3 then
      table.insert(debug_vars, k .. "=" .. (v:len() > 30 and v:sub(1, 30) .. "..." or v))
      count = count + 1
    end
  end

  if #debug_vars > 0 then
    vim.notify("🔍 Exemplos carregados: " .. table.concat(debug_vars, ", "), vim.log.levels.INFO)
  end

  return env
end

-- Função para validar se as variáveis essenciais estão presentes
local function validate_env(env)
  local essential_vars = {
    "spring_profiles_active",
    "DATASOURCE_DBNAME",
    "KAFKA_BOOTSTRAP_SERVERS",
  }

  local missing = {}
  for _, var in ipairs(essential_vars) do
    if not env[var] or env[var] == "" then
      table.insert(missing, var)
    end
  end

  if #missing > 0 then
    vim.notify("⚠️  Variáveis essenciais faltando no .env: " .. table.concat(missing, ", "), vim.log.levels.WARN)
    return false
  end

  return true
end

-- Função para detectar configuração DAP (mantida da versão anterior)
local function detect_dap_config()
  local cwd = vim.fn.getcwd()

  -- 1. Verificar se existe .nvim/dap.lua
  local nvim_dap_path = cwd .. "/.nvim/dap.lua"
  if vim.fn.filereadable(nvim_dap_path) == 1 then
    vim.notify("🔍 Carregando configuração DAP de .nvim/dap.lua", vim.log.levels.INFO)
    local success, config = pcall(dofile, nvim_dap_path)
    if success and config then
      return config
    else
      vim.notify("⚠️  Erro ao carregar .nvim/dap.lua: " .. tostring(config), vim.log.levels.WARN)
    end
  end

  -- 2. Verificar se existe .vscode/launch.json
  local vscode_config_path = cwd .. "/.vscode/launch.json"
  if vim.fn.filereadable(vscode_config_path) == 1 then
    vim.notify("🔍 Convertendo configuração DAP de .vscode/launch.json", vim.log.levels.INFO)

    local vscode_content = vim.fn.readfile(vscode_config_path)
    local content = table.concat(vscode_content, "\n")

    local success, json = pcall(vim.json.decode, content)
    if success and json and json.configurations then
      local dap_configs = {}

      for _, config in ipairs(json.configurations) do
        if config.type == "java" then
          local dap_config = {
            type = "java",
            request = config.request or "launch",
            name = config.name or "Java Application",
            mainClass = config.mainClass,
            projectName = config.projectName or vim.fn.fnamemodify(cwd, ":t"),
            args = config.args,
            vmArgs = config.vmArgs,
            env = config.env,
          }

          if config.request == "attach" then
            dap_config.hostName = config.hostName or "127.0.0.1"
            dap_config.port = config.port or 5005
          end

          table.insert(dap_configs, dap_config)
        end
      end

      if #dap_configs > 0 then
        return dap_configs
      end
    end
  end

  return nil
end

-- Função para detectar main class automaticamente
local function detect_main_class()
  local cwd = vim.fn.getcwd()

  -- Procurar por arquivos Java com método main usando find mais específico
  local find_cmd =
    string.format("find '%s' -name '*.java' -type f -exec grep -l 'public static void main' {} \\; 2>/dev/null", cwd)
  local result = vim.fn.system(find_cmd)

  if vim.v.shell_error == 0 and result ~= "" then
    local main_files = vim.split(result, "\n", { trimempty = true })
    if #main_files > 0 then
      for _, main_file in ipairs(main_files) do
        local content = vim.fn.readfile(main_file)

        local package_name = ""
        local class_name = ""

        for _, line in ipairs(content) do
          local pkg = line:match("^%s*package%s+([%w%.]+);")
          if pkg then
            package_name = pkg
          end

          local cls = line:match("public%s+class%s+(%w+)")
          if cls then
            class_name = cls
            break
          end
        end

        if package_name ~= "" and class_name ~= "" then
          local full_class = package_name .. "." .. class_name
          vim.notify("🎯 Main class detectada: " .. full_class, vim.log.levels.INFO)
          return full_class
        elseif class_name ~= "" then
          vim.notify("🎯 Main class detectada: " .. class_name, vim.log.levels.INFO)
          return class_name
        end
      end
    end
  end

  -- Fallbacks baseados em padrões comuns
  local fallbacks = {
    "Application",
    "DemoApplication",
    "com.example.Application",
    "com.example.DemoApplication",
  }

  for _, fallback in ipairs(fallbacks) do
    vim.notify("⚠️  Usando fallback para main class: " .. fallback, vim.log.levels.WARN)
    return fallback
  end

  return "Application"
end

-- Carregar .env com path absoluto e verificação
local cwd = vim.fn.getcwd()
local env_path = cwd .. "/.env"
local env = load_env_file(env_path)

-- Validar .env
validate_env(env)

return {
  "nvim-java/nvim-java",
  dependencies = {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          jdtls = {
            cmd_env = env, -- injeta no processo do jdtls
            settings = {
              java = {
                configuration = {
                  runtimes = {
                    {
                      name = "Java 21",
                      path = "/Users/johnsouza/.asdf/installs/java/zulu-21.40.17/zulu-21.jdk/Contents/Home",
                    },
                  },
                },
              },
            },
          },
        },
        setup = {
          jdtls = function()
            require("java").setup({
              jdk = {
                auto_install = false,
              },
              root_markers = {
                "settings.gradle",
                "settings.gradle.kts",
                "pom.xml",
                "build.gradle",
                "mvnw",
                "gradlew",
                "build.gradle",
                "build.gradle.kts",
              },
            })

            -- DAP: configuração inteligente com .env robusto
            local dap = require("dap")

            -- Detectar configuração existente
            local existing_configs = detect_dap_config()

            if existing_configs then
              -- Usar configuração existente mas injetar .env
              for _, config in ipairs(existing_configs) do
                config.env = vim.tbl_extend("force", config.env or {}, env)
              end
              dap.configurations.java = existing_configs
              vim.notify("✅ Configuração DAP carregada e .env injetado", vim.log.levels.INFO)
            else
              -- Setup automático
              local main_class = detect_main_class()
              local project_name = vim.fn.fnamemodify(cwd, ":t")

              dap.configurations.java = {
                {
                  type = "java",
                  request = "launch",
                  name = "Launch " .. project_name,
                  mainClass = main_class,
                  projectName = project_name,
                  env = env,
                  args = {},
                  console = "internalConsole",
                },
                {
                  type = "java",
                  request = "launch",
                  name = "Launch with Debug",
                  mainClass = main_class,
                  projectName = project_name,
                  env = vim.tbl_extend("force", env, {
                    SPRING_PROFILES_ACTIVE = "dev",
                    DEBUG = "true",
                  }),
                  args = {},
                  vmArgs = {
                    "-Dspring.profiles.active=" .. (env.spring_profiles_active or "dev"),
                    "-Dlogging.level.root=DEBUG",
                  },
                  console = "internalConsole",
                },
                {
                  type = "java",
                  request = "attach",
                  name = "Attach Spring Boot (5005)",
                  hostName = "127.0.0.1",
                  port = 5005,
                  timeout = 20000,
                },
                {
                  type = "java",
                  request = "attach",
                  name = "Attach Spring Boot (8000)",
                  hostName = "127.0.0.1",
                  port = 8000,
                  timeout = 20000,
                },
              }

              vim.notify("🔧 Configuração DAP automática criada com .env", vim.log.levels.INFO)
            end

            -- Comandos aprimorados
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok then
              wk.add({
                { "<leader>j", group = "Java" },
                {
                  "<leader>jr",
                  function()
                    -- Construir comando com todas as variáveis .env
                    local env_string = ""
                    for k, v in pairs(env) do
                      -- Escapar valores com espaços
                      local escaped_value = v:match("%s") and ('"' .. v .. '"') or v
                      env_string = env_string .. k .. "=" .. escaped_value .. " "
                    end

                    local mvn_cmd = vim.fn.executable("./mvnw") == 1 and "./mvnw" or "mvn"
                    local full_cmd = env_string .. mvn_cmd .. " spring-boot:run"

                    vim.notify(
                      "🚀 Executando: " .. mvn_cmd .. " spring-boot:run com " .. vim.tbl_count(env) .. " variáveis",
                      vim.log.levels.INFO
                    )
                    vim.cmd("TermExec cmd='" .. full_cmd .. "' direction=float")
                  end,
                  desc = "Run Spring Boot with .env",
                },
                {
                  "<leader>je",
                  function()
                    vim.notify("🌍 Variáveis .env carregadas (" .. vim.tbl_count(env) .. "):", vim.log.levels.INFO)
                    local sorted_keys = {}
                    for k in pairs(env) do
                      table.insert(sorted_keys, k)
                    end
                    table.sort(sorted_keys)

                    for _, k in ipairs(sorted_keys) do
                      local v = env[k]
                      local display_value = v:len() > 50 and (v:sub(1, 50) .. "...") or v
                      print(k .. "=" .. display_value)
                    end
                  end,
                  desc = "Show .env variables",
                },
                {
                  "<leader>jv",
                  function()
                    validate_env(env)
                  end,
                  desc = "Validate .env",
                },
                {
                  "<leader>jR",
                  function()
                    -- Recarregar .env
                    env = load_env_file(env_path)
                    validate_env(env)
                    vim.notify("🔄 .env recarregado", vim.log.levels.INFO)
                  end,
                  desc = "Reload .env",
                },
              })
            end
          end,
        },
      },
    },
  },
}
