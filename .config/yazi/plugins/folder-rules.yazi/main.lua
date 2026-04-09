-- sort contents of downloads and media folders by modified time
-- https://yazi-rs.github.io/docs/tips#folder-rules

-- initialize and cache the target paths
local mtime_dirs = (function()
    local dirs = {}
    local targets = { "PICTURES", "VIDEOS", "DOWNLOAD" }

    for _, name in ipairs(targets) do
        local handle = io.popen("xdg-user-dir " .. name)
        if handle then
            -- read and trim whitespace
            local path = handle:read("*a"):gsub("%s+$", "")
            if path ~= "" then
                dirs[path] = true
            end
            handle:close()
        end
    end
    return dirs
end)()

local function is_in_mtime_dir(cwd)
    for path, _ in pairs(mtime_dirs) do
        if cwd:starts_with(path) then
            return true
        end
    end
    return false
end

local function setup()
    local sorted = false
    ps.sub("ind-sort", function(opt)
        local cwd = cx.active.current.cwd
        if is_in_mtime_dir(cwd) then
            if not sorted then
                sorted = true
                opt.by, opt.reverse, opt.dir_first = "mtime", true, false
            end
        else
            if sorted then
                sorted = false
                opt.by, opt.reverse, opt.dir_first = "natural", false, true
            end
        end
        return opt
    end)
end

return { setup = setup }
