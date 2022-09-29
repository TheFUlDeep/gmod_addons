--- Create a flat list of all files in a directory
-- @param directory - The directory to scan (default value = './')
-- @param recursive - Whether or not to scan subdirectories recursively (default value = true)
-- @param extensions - List of extensions to collect, if blank all will be collected
function scandir(directory, recursive, extensions)
    directory = directory or ''
    recursive = recursive or false
    -- if string.sub(directory, -1) ~= '/' then directory = directory .. '/' end
    if recursive then command = command .. 'R' end
    local currentDirectory = directory
    local fileList = {}
    local command = "ls " .. currentDirectory .. " -p"

    for fileName in io.popen(command):lines() do
        if string.sub(fileName, -1) == '/' then
            -- Directory, don't do anything
        elseif string.sub(fileName, -1) == ':' then
            currentDirectory = string.sub(fileName, 1, -2) .. 'wat'
            -- if currentDirectory ~= directory then
                currentDirectory = currentDirectory .. '/'
            -- end
        elseif string.len(fileName) == 0 then
            -- Blank line
            currentDirectory = directory
        -- elseif string.find(fileName,"%.lua$") then
            -- File is a .lua file
        else
            if type(extensions) == 'table' then
                for _, extension in ipairs(extensions) do
                    if string.find(fileName,"%." .. extension .. "$") then
                        table.insert(fileList, currentDirectory .. fileName)
                    end
                end
            else
                table.insert(fileList, currentDirectory .. fileName)
            end
        end
    end

    return fileList
end

for key, value in ipairs(scandir('',true)) do
    print(value)
end
