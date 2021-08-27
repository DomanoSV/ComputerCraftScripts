---------------------------------------
-- DKE FARM TURTLE PROGRAM
-- 
-- This is an auto recoverable farming
-- turtle program. 
---------------------------------------

local configFilename = "turtleFarmConf"
local firstRun = true
local homePosition = false
local startPosition = false
local currentPosition = false
local isFacing = false
local farmWidth = false
local farmLength = false
local startDir = false
local currentTool = false

moveForward = function()
    local hasMoved = false
    local tries = 0

    while not hasMoved do
        if not turtle.forward() then
            if tries > 16 then
                return false
            end
            tries = tries + 1
        else
            if isFacing == 0 then
                currentPosition.z = currentPosition.z - 1
            elseif isFacing == 1 then
                currentPosition.x = currentPosition.x + 1
            elseif isFacing == 2 then 
                currentPosition.z = currentPosition.z + 1
            elseif isFacing == 3 then
                currentPosition.x = currentPosition.x - 1
            end
            settings.set("currentPosition", currentPosition)
            settings.save(configFilename)

            return true
        end
    end
end

turnRight = function()
    if not turtle.turnRight() then
        error('Unable to move.') -- Error will never be seen as turtle can never fail to turn Right.
    else
        isFacing = isFacing + 1

        if isFacing > 3 then
            isFacing = 0
        end

        settings.set("isFacing", isFacing)
        settings.save(configFilename)
    end
end

turnLeft = function()
    if not turtle.turnLeft() then 
        error('Unable to move.') -- Error will never be seen as turtle can never fail to turn left.
    else
        isFacing = isFacing - 1

        if isFacing < 0 then
            isFacing = 3
        end

        settings.set("isFacing", isFacing)
        settings.save(configFilename)
    end
end

-- Find and set starting position
-- @param null
-- @return Position Vector

createStartPosition = function()

    local getPosition = vector.new(gps.locate(5))

    if getPosition ~= nil then
        if type(getPosition.x) == "number" and type(getPosition.y) == "number" and type(getPosition.z) == "number" then
            print("I have found my co-ords, I am at:")
            print("X: " .. getPosition.x)
            print("Y: " .. getPosition.y)
            print("Z: " .. getPosition.z)
            homePosition = getPosition
            return true
        end
    end

    return false
end

lookForClearing = function()
    for i=0,3 do
        if not turtle.detect() then
            return true
        else 
            turtle.turnRight()
            print("I am turning right (" .. i .. ")")
        end
    end   
    
    return false
end

findFacingDir = function()
    local direction = false
    local currentPosition = vector.new(gps.locate(5))

    if lookForClearing() then 
        if turtle.forward() then
            newPosition = vector.new(gps.locate(5))
            vectorValue = newPosition:sub(currentPosition)

            if vectorValue.x == 1 then
                direction = 1
            elseif vectorValue.x == -1 then
                direction = 3
            elseif vectorValue.z == 1 then
                direction = 2
            elseif vectorValue.z == -1 then
                direction = 0
            elseif vectorValue.x ~= 0 and vectorValue ~= 0 then
                print("Something weird happened. Too many variables changed")
            end
        else
            error("I tried to move but was unable too.")
        end
    else
        print('Unable to move. Obstructions all around me.')
    end

    return direction
end

-- Find item in inventory
-- @param itemName string
-- @return false or slot number

findItem = function(itemName)
    for i=1,16,1 do
        local itemDetail = turtle.getItemDetail(i)

        if itemDetail ~= nil then
            if itemDetail.name == itemName then
                return i 
            end
        end
    end 

    return false
end

findEmptySlot = function()
    for i=1,16,1 do
        if turtle.getItemDetail(i) == nil then 
            print(i)
            return i 
        end
    end 

    return false
end

setCurrentTool = function(toolName)
    currentTool = toolName
    settings.set("tool", toolName)
    settings.save(configFilename)
end

-- Add code to handle - What happens if i find a modem? Do i check both sides? 

checkTool = function(toolString)
    if currentTool == toolString then 
        return true
    else
        turtle.select(findEmptySlot())
        turtle.equipRight()

        local toolDetail = turtle.getItemDetail()

        if toolDetail.name == toolString then
            turtle.equipRight()
            print("I have the correct tool to proceed")
            setCurrentTool(toolString)
            return true
        else
            local getslot = findItem(toolString)

            if getslot ~= false then
                turtle.select(getslot)
                turtle.equipRight()
                print("I did not have the correct tool but I found it in my inventory")
                setCurrentTool(toolString)
                return true
            end
        end    
    end
    return false
end

turnToDir = function(direction)
    if direction == 0 then
        if isFacing == 1 then
            turnLeft()
        elseif isFacing == 2 then
            turnRight()
            turnRight()
        elseif isFacing == 3 then
            turnRight()
        end 
    elseif direction == 1 then
        if isFacing == 0 then
            turnRight()
        elseif isFacing == 3 then
            turnLeft()
            turnLeft()
        elseif isFacing == 2 then
            turnLeft()
        end 
    elseif direction == 2 then
        if isFacing == 1 then
            turnRight()
        elseif isFacing == 0 then
            turnLeft()
            turnLeft()
        elseif isFacing == 3 then
            turnLeft()
        end
    elseif direction == 3 then
        if isFacing == 0 then
            turnLeft()
        elseif isFacing == 1 then
            turnRight()
            turnRight()
        elseif isFacing == 2 then
            turnRight()
        end
    end

    if isFacing == direction then return true end
end

goToPosition = function(value)
    print(value)

    while currentPosition.z ~= value.z do
        if value.z > currentPosition.z then
            if isFacing ~= 2 then
                turnToDir(2)
            end
            moveForward()
        elseif value.z < currentPosition.z then
            if isFacing ~= 0 then
                turnToDir(0)
            end
            moveForward()
        end
    end

    while currentPosition.x ~= value.x do
        if value.x > currentPosition.x then
            if isFacing ~= 1 then
                turnToDir(1)
            end
            moveForward()
        elseif value.x < currentPosition.x then
            if isFacing ~= 3 then
                turnToDir(3)
            end
            moveForward()
        end
    end
end

-- Add code to initalization to check i have a modem or erro out if not.


-- Initalise farming turtle program
-- @param nil
-- @return nil

init = function()
    if not settings.load(configFilename) then
        local startPoint = vector.new(-6, 0, -2)
        settings.set("firstRun", true)
        settings.set("homePosition", false)
        settings.set("currentPosition", false)
        settings.set("isFacing", false)
        settings.set("startPosition", startPoint)
        settings.set("tool", false)
        settings.set("farmWidth", 10)
        settings.set("farmLength", 10)
        settings.set("startDir", 0)
        settings.save(configFilename)
    end

    firstRun = settings.get("firstRun")
    homePosition = settings.get("homePosition")
    startPosition = settings.get("startPosition")
    currentPosition = settings.get("currentPosition")
    isFacing = settings.get("isFacing")
    farmWidth = settings.get("farmWidth")
    farmLength = settings.get("farmLength")
    startDir = settings.get("startDir")
    currentTool = settings.get("tool")

    if firstRun then 
        print("Finding out my current location")
        if createStartPosition() then
            print("Saving first run information")
            settings.set("homePosition", homePosition)
            settings.set("currentPosition", homePosition)
            settings.set("firstRun", false)
            settings.save(configFilename)
        else
            error("Something went wrong")
        end
    end

    print("I am now going to work out what direction I am facing")

    if turtle.getFuelLevel() > 2 then 
        local findDir = findFacingDir()
        local directionString = false

        if findDir ~= false and type(findDir) == "number" and findDir >= 0 and findDir <= 3 then
            isFacing = findDir
        else
            error("Error in determining facing direction")
        end
    
        turtle.turnRight()
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()
        turtle.turnRight()
    
        if isFacing == 0 then
            directionString = "North"
        elseif isFacing == 1 then
            directionString = "East"
        elseif isFacing == 2 then 
            directionString = "South"
        elseif isFacing == 3 then
            directionString = "West"
        end

        currentPosition = vector.new(gps.locate(5))    

        settings.set("currentPosition", currentPosition)
        settings.set("isFacing", isFacing)
        settings.save(configFilename)

        print("I am facing " .. directionString)
    
    else
        error("I do not have enough fuel for this operation")
    end

    print("Initalization has been completed ...")
end

init()

homePostionVector = vector.new(homePosition.x, homePosition.y, homePosition.z)
startPositionVector =  vector.new(startPosition.x, startPosition.y, startPosition.z)

newPosition = homePostionVector:add(startPositionVector)

goToPosition(newPosition)
turnToDir(startDir)

local test = { x = 0, y = 0, z = 0}

currentPositionVector =  vector.new(currentPosition.x, currentPosition.y, currentPosition.z)

if startDir == 0 then 
    test.z = (currentPosition.z - 1) - farmLength  
    test.x = currentPosition.x + farmWidth
end

local setup = true

while true do 
    local xPos, zPos = 0

    if startDir == 0 then
        zPos = (test.z - currentPosition.z) + farmLength
        xPos = (currentPosition.x - test.x) + farmWidth    
    end

    if setup then 
        checkTool("minecraft:diamond_pickaxe")
        if xPos == 0 or zPos == 0 or xPos == farmWidth or zPos == farmLength then  
            turtle.digDown()
        end

        if math.fmod(xPos, 5) == 0 and math.fmod(zPos, 5) == 0 and zPos > 0 and zPos < farmLength and xPos > 0 and xPos < farmWidth then
            turtle.up()
            sleep(1)
            turtle.down()
            print("water here")
            turtle.digDown()
        else
            print("dirt here")
        end
    else
        checkTool("minecraft:diamond_hoe")
    end

    if zPos == farmLength and xPos < farmWidth then
        turnRight()
        moveForward()
        turnRight()
    end

    if zPos == 0 and xPos ~= 0 and xPos < farmWidth then
        turnLeft()
        moveForward()
        turnLeft()
    end

    if zPos >= farmLength and xPos >= farmWidth or zPos == 0 and xPos >= farmWidth then
        goToPosition(newPosition)
        turnToDir(startDir)
        setup = false
    end

    moveForward()
end
