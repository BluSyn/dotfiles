-- ghostcalc.lua
-- A Neovim plugin for inline math, unit conversions, and smart line referencing.
-- Usage:
--   10 + 10            -> = 20
--   x = 5 in           -> = 5 in (Stored as 'x')
--   @x to cm           -> = 12.7 cm
--   @ + 2              -> Result of previous line + 2
--   #1 + 5             -> Reference line 1

local M = {}
local api = vim.api
local ns_id = api.nvim_create_namespace("GhostCalc")
local data_path = vim.fn.stdpath("data") .. "/ghostcalc_rates.json"

-- Module-level storage for variables: buffer_vars[bufnr][var_name] = { val=num, unit=str }
local buffer_vars = {}

-- Configuration
local config = {
    enabled = false,
    autostart_filetypes = { "text", "conf", "markdown" },
    virtual_text_prefix = " = ",
    highlight_group = "Comment",
    precision = 4,
}

---------------------------------------------------------
-- 1. CONSTANTS & UNITS
---------------------------------------------------------

local constants = {
    pi = math.pi,
    tau = math.pi * 2,
    e = math.exp(1),
    phi = 1.6180339887,
}

-- Helper to create aliases without repeating tables
local function alias(tbl, val_obj, keys)
    for _, key in ipairs(keys) do
        tbl[key] = val_obj
    end
end

local units = {}

-- --- DEFINITIONS ---

-- LENGTH (Base: mm)
local u_mm  = { val = 1.0, category = "len" }
local u_cm  = { val = 10.0, category = "len" }
local u_m   = { val = 1000.0, category = "len" }
local u_km  = { val = 1000000.0, category = "len" }
local u_in  = { val = 25.4, category = "len" }
local u_ft  = { val = 304.8, category = "len" }
local u_yd  = { val = 914.4, category = "len" }
local u_mi  = { val = 1609344.0, category = "len" }

alias(units, u_mm, { "mm", "millimeter", "millimeters" })
alias(units, u_cm, { "cm", "centimeter", "centimeters" })
alias(units, u_m, { "m", "meter", "meters" })
alias(units, u_km, { "km", "kilometer", "kilometers" })
alias(units, u_in, { "in", "inch", "inches" })
alias(units, u_ft, { "ft", "foot", "feet" })
alias(units, u_yd, { "yd", "yard", "yards" })
alias(units, u_mi, { "mi", "mile", "miles" })

-- MASS (Base: g)
local u_mg = { val = 0.001, category = "mass" }
local u_g  = { val = 1.0, category = "mass" }
local u_kg = { val = 1000.0, category = "mass" }
local u_oz = { val = 28.3495, category = "mass" }
local u_lb = { val = 453.592, category = "mass" }

alias(units, u_mg, { "mg", "milligram", "milligrams" })
alias(units, u_g, { "g", "gram", "grams" })
alias(units, u_kg, { "kg", "kilogram", "kilograms" })
alias(units, u_oz, { "oz", "ounce", "ounces" })
alias(units, u_lb, { "lb", "lbs", "pound", "pounds" })

-- SPEED (Base: m/s)
local u_mps = { val = 1.0, category = "speed" }
local u_kph = { val = 0.277778, category = "speed" }
local u_mph = { val = 0.44704, category = "speed" }

alias(units, u_mps, { "mps" })
alias(units, u_kph, { "kph" })
alias(units, u_mph, { "mph" })

-- VOLUME (Base: ml)
local u_ml  = { val = 1.0, category = "vol" }
local u_l   = { val = 1000.0, category = "vol" }
local u_qt  = { val = 946.353, category = "vol" }
local u_pt  = { val = 473.176, category = "vol" }
local u_gal = { val = 3785.41, category = "vol" }

alias(units, u_ml, { "ml", "milliliter", "milliliters" })
alias(units, u_l, { "l", "liter", "liters" })
alias(units, u_qt, { "qt", "quart", "quarts" })
alias(units, u_pt, { "pt", "pint", "pints" })
alias(units, u_gal, { "gal", "gallon", "gallons" })

-- TIME (Base: s)
local u_s   = { val = 1.0, category = "time" }
local u_min = { val = 60.0, category = "time" }
local u_hr  = { val = 3600.0, category = "time" }
local u_day = { val = 86400.0, category = "time" }
local u_wk  = { val = 604800.0, category = "time" }
local u_mo  = { val = 2629746.0, category = "time" }
local u_yr  = { val = 31556952.0, category = "time" }

alias(units, u_s, { "s", "sec", "secs", "second", "seconds" })
alias(units, u_min, { "min", "mins", "minute", "minutes" })
alias(units, u_hr, { "hr", "hrs", "hour", "hours" })
alias(units, u_day, { "day", "days" })
alias(units, u_wk, { "wk", "week", "weeks" })
alias(units, u_mo, { "mo", "mos", "month", "months" })
alias(units, u_yr, { "yr", "yrs", "year", "years" })

-- DATA (Base: b - using Byte for now)
local u_b  = { val = 1.0, category = "data" }
local u_kb = { val = 1000.0, category = "data" }
local u_mb = { val = 1000000.0, category = "data" }
local u_gb = { val = 1000000000.0, category = "data" }
local u_tb = { val = 1000000000000.0, category = "data" }

alias(units, u_b, { "b", "byte", "bytes" })
alias(units, u_kb, { "kb", "kilobyte", "kilobytes" })
alias(units, u_mb, { "mb", "megabyte", "megabytes" })
alias(units, u_gb, { "gb", "gigabyte", "gigabytes" })
alias(units, u_tb, { "tb", "terabyte", "terabytes" })

-- TEMP
local u_c = { category = "temp" }
local u_f = { category = "temp" }
local u_k = { category = "temp" }

alias(units, u_c, { "c", "celsius" })
alias(units, u_f, { "f", "fahrenheit" })
alias(units, u_k, { "k", "kelvin" })

-- CURRENCY (Base: USD)
local u_usd = { val = 1.0, category = "curr" }
-- These defaults are fallbacks if API fails/never run
local u_eur = { val = 1.05, category = "curr" }
local u_gbp = { val = 1.27, category = "curr" }
local u_cad = { val = 0.71, category = "curr" }
local u_aud = { val = 0.65, category = "curr" }
local u_chf = { val = 1.13, category = "curr" }
local u_sgd = { val = 0.74, category = "curr" }
local u_cny = { val = 0.138, category = "curr" }
local u_hkd = { val = 0.128, category = "curr" }
local u_jpy = { val = 0.0065, category = "curr" }
local u_php = { val = 0.017, category = "curr" }
local u_inr = { val = 0.011, category = "curr" }
local u_krw = { val = 0.0007, category = "curr" }
local u_btc = { val = 95000.0, category = "curr" }
local u_eth = { val = 3200.0, category = "curr" }

alias(units, u_usd, { "usd", "dollar", "dollars" })
alias(units, u_eur, { "eur", "euro", "euros" })
alias(units, u_gbp, { "gbp" })
alias(units, u_cad, { "cad" })
alias(units, u_aud, { "aud" })
alias(units, u_chf, { "chf" })
alias(units, u_sgd, { "sgd" })
alias(units, u_cny, { "cny", "yuan" })
alias(units, u_hkd, { "hkd" })
alias(units, u_jpy, { "jpy", "yen" })
alias(units, u_php, { "php", "peso", "pesos" })
alias(units, u_inr, { "inr", "rupee", "rupees" })
alias(units, u_krw, { "krw", "won" })
alias(units, u_btc, { "btc", "bitcoin" })
alias(units, u_eth, { "eth", "ethereum" })


local function round(num)
    local mult = 10 ^ config.precision
    return math.floor(num * mult + 0.5) / mult
end

local function convert_temperature(amount, from, to)
    if from == to then return amount end
    local c_val = amount
    if from == "f" or from == "fahrenheit" then
        c_val = (amount - 32) * 5 / 9
    elseif from == "k" or from == "kelvin" then
        c_val = amount - 273.15
    end
    if to == "c" or to == "celsius" then
        return c_val
    elseif to == "f" or to == "fahrenheit" then
        return (c_val * 9 / 5) + 32
    elseif to == "k" or to == "kelvin" then
        return c_val + 273.15
    end
    return 0
end

local function get_conversion_value(amount, from_unit, to_unit)
    local u1 = units[from_unit]
    local u2 = units[to_unit]
    if not u1 or not u2 then return nil end
    if u1.category ~= u2.category then return nil end
    if u1.category == "temp" then return convert_temperature(amount, from_unit, to_unit) end
    return amount * (u1.val / u2.val)
end

---------------------------------------------------------
-- 2. CURRENCY UPDATE LOGIC (API)
---------------------------------------------------------

-- Forward declaration
local refresh_buffer

function M.apply_rates(rates)
    local curr_map = {
        eur = "EUR",
        gbp = "GBP",
        cad = "CAD",
        aud = "AUD",
        chf = "CHF",
        sgd = "SGD",
        cny = "CNY",
        hkd = "HKD",
        jpy = "JPY",
        php = "PHP",
        inr = "INR",
        krw = "KRW",
        btc = "BTC",
        eth = "ETH"
    }
    for key, api_code in pairs(curr_map) do
        local rate = rates[api_code]
        if rate and rate > 0 and units[key] then
            units[key].val = 1 / rate
        end
    end
    if units['usd'] then units['usd'].val = 1.0 end
    if refresh_buffer then refresh_buffer() end
end

function M.load_rates()
    local file = io.open(data_path, "r")
    if not file then return end
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.rates then M.apply_rates(data.rates) end
end

function M.update_rates()
    print("GhostCalc: Fetching live rates (Fiat)...")
    local url = "https://open.er-api.com/v6/latest/USD"
    local cmd = string.format("curl -s '%s'", url)
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then return end
    local ok, data = pcall(vim.json.decode, output)
    if not ok or not data or not data.rates then return end

    print("GhostCalc: Fetching live rates (Crypto)...")
    local url_crypto = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd"
    local out_crypto = vim.fn.system(string.format("curl -s '%s'", url_crypto))
    local ok_c, data_c = pcall(vim.json.decode, out_crypto)
    if ok_c and data_c then
        if data_c.bitcoin and data_c.bitcoin.usd then data.rates["BTC"] = 1 / data_c.bitcoin.usd end
        if data_c.ethereum and data_c.ethereum.usd then data.rates["ETH"] = 1 / data_c.ethereum.usd end
    end

    local file = io.open(data_path, "w")
    if file then
        file:write(vim.json.encode(data))
        file:close()
    end
    M.apply_rates(data.rates)
    print("GhostCalc: Rates updated successfully.")
end

---------------------------------------------------------
-- 3. TEXT PROCESSING PIPELINE
---------------------------------------------------------

local function parse_number(str)
    if not str then return nil end
    local clean = str:gsub(",", "")
    return tonumber(clean)
end

local function extract_number_from_text(text)
    local last_num_str = nil
    for num_str in text:gmatch("[%d%,%.]+") do
        if num_str:find("%d") then last_num_str = num_str end
    end
    return parse_number(last_num_str)
end

-- Updated: Returns number AND unit if found
local function resolve_line_refs(bufnr, text, depth)
    depth = depth or 0
    if depth > 3 then return nil end

    local resolved_text = text:gsub("#(%d+)", function(line_num_str)
        local line_num = tonumber(line_num_str)
        if not line_num or line_num < 1 then return "0" end

        local lines = api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)
        if #lines == 0 then return "0" end

        local ref_content = lines[1]
        local result, unit = M.calculate_value_only(bufnr, ref_content, depth + 1, line_num)

        if result then
            -- Return "Value Unit" to allow downstream conversions
            return tostring(result) .. (unit and (" " .. unit) or "")
        end

        -- Fallback to static extraction (naive)
        local static_num = extract_number_from_text(ref_content)
        if static_num then return tostring(static_num) end

        return "0"
    end)

    return resolved_text
end

local function process_nested_conversions(text)
    local changed = false
    local target_unit = nil
    -- Match "10 unit to unit"
    local processed = text:gsub("([%d%,%.]+)%s*([%a]+)%s+[tT][oO]%s+([%a]+)", function(amount_str, from, to)
        local val = get_conversion_value(parse_number(amount_str), from:lower(), to:lower())
        if val then
            changed = true
            target_unit = to -- Capture unit for result propagation
            return tostring(val)
        end
        return amount_str .. " " .. from .. " to " .. to
    end)
    return processed, changed, target_unit
end

local function process_percentages(text)
    text = text:gsub("([%d%.]+)%%%s+of%s+([%d%,%.]+)", function(pct, val_str)
        return string.format("((%s/100) * %s)", pct, parse_number(val_str))
    end)
    text = text:gsub("([%d%,%.]+)%s*([%+%-]+)%s*([%d%.]+)%%", function(base_str, op, pct)
        local base = parse_number(base_str)
        return string.format("%s %s (%s * %s / 100)", base, op, base, pct)
    end)
    text = text:gsub("([%d%.]+)%%", function(num)
        return string.format("(%s / 100)", num)
    end)
    return text
end

local function strip_noise(text)
    text = text:gsub("([%d]+),([%d]+)", "%1%2")
    -- Strip units but keep numbers
    local processed = text:gsub("([%d%.]+)%s*([%a]+)", function(num, unit)
        if units[unit:lower()] then return num end
        return num .. unit
    end)
    return processed
end

---------------------------------------------------------
-- 4. MAIN EVALUATION LOGIC
---------------------------------------------------------

-- Updated signature: returns (value, unit)
function M.calculate_value_only(bufnr, text, depth, line_num)
    if text == nil or text == "" then return nil end

    -- 1. Detect Assignment: var_name = expression
    local assign_var
    local var_name, expr = text:match("^%s*([%a_][%w_]*)%s*=%s*(.*)$")
    if var_name and expr then
        assign_var = var_name
        text = expr
    end

    -- 2. Substitute Variables (@name)
    -- Expand to "Value Unit" so unit context is preserved in string
    text = text:gsub("@([%a_][%w_]*)", function(v_name)
        if not buffer_vars[bufnr] then return "0" end
        local data = buffer_vars[bufnr][v_name]
        if not data then return "0" end

        if type(data) == "table" and data.unit then
            return data.val .. " " .. data.unit
        elseif type(data) == "table" then
            return tostring(data.val)
        else
            return tostring(data)
        end
    end)

    -- 3. Substitute Previous Line (@) -> Maps to #PREV
    if line_num and text:find("@") then
        local prev_line = line_num - 1
        if prev_line > 0 then
            text = text:gsub("@", "#" .. prev_line)
        else
            text = text:gsub("@", "0")
        end
    end

    -- 4. Resolve References
    -- resolve_line_refs now returns string with units if applicable
    local work_text = resolve_line_refs(bufnr, text, depth)
    if not work_text then return nil end

    -- 5. Process Conversions
    -- Capture target unit if conversion happens
    local work_text_conv, was_converted, conv_unit = process_nested_conversions(work_text)
    work_text = work_text_conv

    -- 6. Scan for Dominant Unit (before stripping)
    -- If conversion happened, that's the unit. Else, look for explicit units in text.
    local detected_unit = conv_unit
    if not detected_unit then
        for num, unit in work_text:gmatch("([%d%.]+)%s*([%a]+)") do
            if units[unit:lower()] then
                detected_unit = unit
                break -- take first valid unit
            end
        end
    end

    work_text = process_percentages(work_text)
    work_text = strip_noise(work_text)

    -- Sanitize
    if work_text:find("[^%d%s%.%+%-%*%/%^%(%)pi%a]") then
        if not work_text:find("[%+%-%*%/%^]") and not work_text:find("sin") and not work_text:find("cos") then
            return nil
        end
    end

    local sandbox = vim.tbl_extend("force", {
        math = math,
        abs = math.abs,
        floor = math.floor,
        ceil = math.ceil,
        max = math.max,
        min = math.min,
        sin = math.sin,
        cos = math.cos,
        tan = math.tan,
        deg = math.deg,
        rad = math.rad,
        sqrt = math.sqrt,
        random = math.random
    }, constants)

    local func = load("return " .. work_text, "calc", "t", sandbox)
    if not func then return nil end

    local status, result = pcall(func)

    if status and type(result) == "number" then
        -- Helper to store variable with unit info
        local function store_var()
            if assign_var then
                if not buffer_vars[bufnr] then buffer_vars[bufnr] = {} end
                buffer_vars[bufnr][assign_var] = { val = result, unit = detected_unit }
            end
        end

        if not was_converted then
            local stripped_input = work_text:gsub("%s+", "")
            if tostring(result) == stripped_input then
                store_var()
                return nil
            end
        end

        store_var()
        return result, detected_unit
    end

    return nil
end

-- Main public entry
function M.calculate(bufnr, text, line_num)
    -- Display Case: explicit conversion
    local amount_str, from, to = text:match("^%s*([%d%,%.]+)%s*([%a]+)%s+to%s+([%a]+)%s*$")
    if amount_str and from and to then
        local val = get_conversion_value(parse_number(amount_str), from:lower(), to:lower())
        if val then return round(val) .. " " .. to end
    end

    local pre_as_content = text:match("^(.*)%s+as%s+%%%s*$")
    if pre_as_content then
        local val = M.calculate_value_only(bufnr, pre_as_content, 0, line_num)
        if val then
            return round(val * 100) .. " %"
        end
    end

    -- Regular Calculation
    local val, unit = M.calculate_value_only(bufnr, text, 0, line_num)
    if val then
        if unit then
            return round(val) .. " " .. unit
        end
        return round(val)
    end
    return nil
end

---------------------------------------------------------
-- 5. UI & EVENT HANDLER
---------------------------------------------------------

refresh_buffer = function()
    if vim.b.ghostcalc_enabled == nil then
        local ft = vim.bo.filetype
        local auto_enable = false
        if vim.tbl_contains(config.autostart_filetypes, ft) then
            auto_enable = true
        end
        vim.b.ghostcalc_enabled = config.enabled or auto_enable
    end

    if not vim.b.ghostcalc_enabled then return end

    local bufnr = api.nvim_get_current_buf()
    if not api.nvim_buf_is_valid(bufnr) then return end

    buffer_vars[bufnr] = {}

    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    for i, line_text in ipairs(lines) do
        local result = M.calculate(bufnr, line_text, i)
        if result then
            local virt_text = { { config.virtual_text_prefix .. tostring(result), config.highlight_group } }
            api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
                virt_text = virt_text,
                virt_text_pos = 'eol',
                hl_mode = 'combine',
            })
        end
    end
end

function M.setup(opts)
    if opts then config = vim.tbl_extend("force", config, opts) end
    M.load_rates()
    api.nvim_create_user_command("GhostCalcUpdateRates", function() M.update_rates() end, {})
    local group = api.nvim_create_augroup("GhostCalc", { clear = true })
    api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI" }, {
        group = group,
        callback = refresh_buffer,
    })
    api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(args) buffer_vars[args.buf] = nil end,
    })
end

function M.toggle()
    if vim.b.ghostcalc_enabled == nil then vim.b.ghostcalc_enabled = config.enabled end
    vim.b.ghostcalc_enabled = not vim.b.ghostcalc_enabled
    if not vim.b.ghostcalc_enabled then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
        print("GhostCalc: Off")
    else
        refresh_buffer()
        print("GhostCalc: On")
    end
end

return M
