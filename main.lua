-- Variables for colors
backgroundColor = {0.1, 0.1, 0.3} -- Dark blue background
artistColor = {1, 1, 0.5} -- Light yellow
titleColor = {0.5, 1, 0.5} -- Light green
instructionColor = {0.7, 0.7, 1} -- Light blue
lyricsColors = {
    {1, 0.5, 0.5}, -- Light red
    {0.5, 1, 0.5}, -- Light green
    {0.5, 0.5, 1}, -- Light blue
    {1, 1, 0.5},   -- Light yellow
    {1, 0.5, 1}    -- Light pink
}

scrollY = 0
scrollSpeed = 20
currentPage = "input" -- "input" or "lyrics"

-- Variables for rain effect
raindrops = {}
raindropCount = 100 -- Number of raindrops
raindropSpeedMin = 2 -- Minimum speed of raindrops
raindropSpeedMax = 6 -- Maximum speed of raindrops

function love.load()
    love.window.setTitle("Lyrics Finder")
    love.window.setMode(800, 600)
    
    artist = ""
    title = ""
    lyrics = ""
    searchTriggered = false
    
    -- Initialize raindrops
    for i = 1, raindropCount do
        table.insert(raindrops, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(raindropSpeedMin, raindropSpeedMax)
        })
    end
    
    -- Automatically check Spotify status and fetch lyrics
    checkSpotifyAndFetchLyrics()
end

function love.update(dt)
    if currentPage == "lyrics" then
        -- Update raindrops
        for _, drop in ipairs(raindrops) do
            drop.y = drop.y + drop.speed
            if drop.y > love.graphics.getHeight() then
                drop.y = 0
                drop.x = math.random(0, love.graphics.getWidth())
            end
        end
    end
end

function love.textinput(text)
    if currentPage == "input" then
        if searchTriggered then
            artist = artist .. text
        else
            title = title .. text
        end
    end
end

function love.keypressed(key)
    if key == "return" then
        if currentPage == "input" then
            searchLyrics()
            currentPage = "lyrics"
        end
    elseif key == "tab" then
        if currentPage == "input" then
            searchTriggered = not searchTriggered
            if searchTriggered then
                artist = ""
            else
                title = ""
            end
        end
    elseif key == "backspace" then
        if currentPage == "input" then
            if searchTriggered then
                artist = artist:sub(1, -2)
            else
                title = title:sub(1, -2)
            end
        end
    elseif key == "up" then
        if currentPage == "lyrics" then
            scrollY = scrollY - scrollSpeed
        end
    elseif key == "down" then
        if currentPage == "lyrics" then
            scrollY = scrollY + scrollSpeed
        end
    elseif key == "escape" then
        if currentPage == "lyrics" then
            currentPage = "input"
            scrollY = 0 -- Reset scroll position when going back to input
        end
    end
end

function checkSpotifyAndFetchLyrics()
    -- Run the `spotify status` command and capture its output
    local handle_music = io.popen("python3 spy_music.py")
    local result_music = handle_music:read("*a")
    handle_music:close()

    local handle_artist = io.popen("python3 spy_artist.py")
    local result_artist = handle_artist:read("*a")
    handle_artist:close()

    local handle_status = io.popen("python3 spy_status.py")
    local result_status = handle_status:read("*a")
    handle_status:close()
    result_status = result_status:gsub("^%s*(.-)%s*$", "%1")
    
    if result_status == "true" then
        artist, title = result_artist, result_music
        searchLyrics()
        currentPage = "lyrics"
    else
        artist, title = "", ""
        lyrics = "Spotify is not playing or song information not found."
    end
end

function searchLyrics()
    local artist_enc = artist:gsub(" ", "%%20")
    local title_enc = title:gsub(" ", "%%20")
    
    -- Run the Python script and capture its output
    local command = string.format('python3 fetch_lyrics.py "%s" "%s"', artist_enc, title_enc)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    -- Process the result
    lyrics = result or "Lyrics not found or error occurred. (probably some unknown bullshit language)"
end

function love.draw()
    -- Set background color
    love.graphics.clear(backgroundColor)
    
    if currentPage == "input" then
        -- Set colors for artist, title, and instructions
        love.graphics.setColor(artistColor)
        love.graphics.print("Artist: " .. artist, 10, 10)
        
        love.graphics.setColor(titleColor)
        love.graphics.print("Title: " .. title, 10, 30)
        
        love.graphics.setColor(instructionColor)
        
        love.graphics.print("Press TAB to switch input field", 10, 50)
        love.graphics.print("Press RETURN to search", 10, 70)
        love.graphics.print("Press ESC to go back to input page from lyrics", 10, 90)
    elseif currentPage == "lyrics" then
        -- Draw the rain effect
        love.graphics.setColor(1, 1, 1, 0.5) -- Light white, slightly transparent
        for _, drop in ipairs(raindrops) do
            love.graphics.line(drop.x, drop.y, drop.x, drop.y + 10)
        end
        
        -- Set the starting y position based on scrollY
        local startY = 30 - scrollY
        local lineHeight = 20 -- Adjust line height as needed
        
        -- Render each line of the lyrics centered with alternating colors
        for i, line in ipairs(lyrics:split("\n")) do
            -- Calculate the width of the line
            local lineWidth = love.graphics.getFont():getWidth(line)
            
            -- Calculate the x-position to center the line
            local xPos = (love.graphics.getWidth() - lineWidth) / 2
            
            -- Cycle through the colors
            local color = lyricsColors[(i - 1) % #lyricsColors + 1]
            love.graphics.setColor(color)
            love.graphics.print(line, xPos, startY + (i - 1) * lineHeight)
        end
    end
end

-- Helper function to split a string by newline
function string:split(delimiter)
    local result = {}
    for match in (self..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end
