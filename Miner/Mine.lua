-- Variables                        --
local turtleState = {}
local inputChest = {}
local outputChest = {}
local fuelChest = {}

turtleStateFilename = "turtleState"

-- Functions                        --

findItem = function(itemName)
    for i=1,16,1 do 
        itemData = turtle.getItemDetail(i)

        if itemData ~= nil then 
            if itemData.name == itemName then 
                return i
            end
        end
    end 

    return false
end

selectInventoryItem = function(itemName)
    if not findItem(itemName) then
        print("Can't find item: ", itemName, " in the inventory.")
        print("Returning home to re-stock")

        local x = xPos
        local y = yPos
        local z = zPos
        local f = isFacing

        returnHome()

        while not findItem(itemName) do
            print("Waiting for ", itemName, " to be put in inventory.")
            sleep(2)
        end

        returnToPos(x,y,z,f)
    end

    return turtle.select(findItem(itemName))
end

placeBlock = function(itemName)
    selectInventoryItem(itemName)
    turtle.place()
end

placeUpBlock = function(itemName)
    selectInventoryItem(itemName)
    turtle.placeUp()
end

placeDownBlock = function(itemName)
    selectInventoryItem(itemName)
    turtle.placeDown()
end

turnRight = function()
    if not turtle.turnRight() then
        error('Unable to move.') -- Error will never be seen as turtle can never fail to turn left.
    else
        isFacing = isFacing + 1

        if isFacing > 3 then
            isFacing = 0
        end

        settings.set("isFacing", isFacing)
        settings.save(turtleStateFilename)
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
        settings.save(turtleStateFilename)
    end
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

moveForward = function()
    local hasMoved = false
    local tries = 0

    while not hasMoved do
        if not turtle.forward() then
            if tries == 16 then
                error("Unable to move.")
            end

            turtle.dig()
            tries = tries + 1
        else
            if isFacing == 0 then
                xPos = xPos + 1
                settings.set("xPos", xPos)
            elseif isFacing == 1 then
                yPos = yPos + 1
                settings.set("yPos", yPos)
            elseif isFacing == 2 then 
                xPos = xPos - 1
                settings.set("xPos", xPos)
            elseif isFacing == 3 then
                yPos = yPos - 1
                settings.set("yPos", yPos)
            end
            settings.save(turtleStateFilename)
            hasMoved = true
        end
    end
end

moveBackward = function()
    if not turtle.back() then
        error("Unable to move.")
    else
        if isFacing == 0 then
            xPos = xPos - 1
            settings.set("xPos", xPos)
        elseif isFacing == 1 then
            yPos = yPos - 1
            settings.set("yPos", yPos)
        elseif isFacing == 2 then 
            xPos = xPos + 1
            settings.set("xPos", xPos)
        elseif isFacing == 3 then
            yPos = yPos + 1
            settings.set("yPos", yPos)
        end
        settings.save(turtleStateFilename)
    end
end

moveUp = function()
    if not turtle.up() then
        error("Unable to move.")
    else
        zPos = zPos + 1
        settings.set("zPos", zPos)
        settings.save(turtleStateFilename)
    end
end

moveDown = function()
    if not turtle.down() then
        error("Unable to move.")
    else
        zPos = zPos - 1
        settings.set("zPos", zPos)
        settings.save(turtleStateFilename)
    end
end
    

returnToPos = function(x,y,z,f)
    while xPos ~= x do
        if xPos > x then 
            if isFacing == 1 then
                turnRight()
            elseif isFacing == 0 then
                turnLeft()
                turnLeft()
            elseif isFacing == 3 then
                turnLeft()
            end 
            moveForward()
        elseif xPos < x then 
            if isFacing == 1 then
                turnLeft()
            elseif isFacing == 2 then
                turnRight()
                turnRight()
            elseif isFacing == 3 then
                turnRight()
            end 
            moveForward()
        end
    end

    while yPos ~= y do
        if x >= -1 then
            if xPos == -1 then
                if isFacing == 1 then
                    turnLeft()
                elseif isFacing == 2 then
                    turnRight()
                    turnRight()
                elseif isFacing == 3 then
                    turnRight()
                end 
                moveForward()
            end
        else
            if isFacing == 1 then
                turnRight()
            elseif isFacing == 0 then
                turnRight()
                turnRight()
            elseif isFacing == 3 then
                turnLeft()
            end 
            moveForward()
        end

        if yPos > y then 
            if isFacing == 0 then
                turnLeft()
            elseif isFacing == 1 then
                turnRight()
                turnRight()
            elseif isFacing == 2 then
                turnRight()
            end 
            moveForward()
        elseif yPos < y then 
            if isFacing == 0 then
                turnRight()
            elseif isFacing == 3 then
                turnLeft()
                turnLeft()
            elseif isFacing == 2 then
                turnLeft()
            end 
            moveForward()
        end
    end

    while zPos ~= z do
        if zPos > z then
            moveDown()
        elseif zPos < z then
            moveUp()
        end
    end

    turnToDir(f)
end

returnHome = function()
    while zPos ~= 0 do
        if zPos > 0 then
            moveDown()
        elseif zPos < 0 then
            moveUp()
        end
    end

    while yPos ~= 0 do
        if xPos == 0 then
            if isFacing == 1 then
                turnLeft()
            elseif isFacing == 2 then
                turnRight()
                turnRight()
            elseif isFacing == 3 then
                turnRight()
            end 
            moveForward()
        end

        if yPos > 0 then 
            if isFacing == 0 then
                turnLeft()
            elseif isFacing == 1 then
                turnRight()
                turnRight()
            elseif isFacing == 2 then
                turnRight()
            end 

            moveForward()
        elseif yPos < 0 then 
            if isFacing == 0 then
                turnRight()
            elseif isFacing == 3 then
                turnLeft()
                turnLeft()
            elseif isFacing == 2 then
                turnLeft()
            end 

            moveForward()
        end
    end

    while xPos ~= 0 do
        if xPos > 0 then 
            if isFacing == 1 then
                turnRight()
            elseif isFacing == 0 then
                turnLeft()
                turnLeft()
            elseif isFacing == 3 then
                turnLeft()
            end 

            moveForward()
        elseif xPos < 0 then 
            if isFacing == 1 then
                turnLeft()
            elseif isFacing == 2 then
                turnRight()
                turnRight()
            elseif isFacing == 3 then
                turnRight()
            end 

            moveForward()
        end
    end

    if xPos == 0 and yPos == 0 then
        if isFacing == 1 then
            turnLeft()
        elseif isFacing == 2 then
            turnRight()
            turnRight()
        elseif isFacing == 3 then
            turnRight()
        end
    end  

    print("I AM HOME!")

end

local ignoreBlocksDefault =  {
    "minecraft:andesite",
    "minecraft:bedrock",
    "minecraft:cobblestone",
    "minecraft:diorite",
    "minecraft:dirt",
    "minecraft:granite",
    "minecraft:gravel",
    "minecraft:red_sand",
    "minecraft:sand",
    "minecraft:stone",
    "minecraft:stone_bricks",
}

if not settings.load(turtleStateFilename) then 
    settings.set("xSize", 9)
    settings.set("ySize", 9)
    settings.set("xPos", 0)
    settings.set("yPos", 0)
    settings.set("zPos", 0)
    settings.set("isFacing", 0)
    settings.set("firstRun", true)
    settings.set("aboveGround", true)
    settings.set("currentStep", {})
    settings.set("ignoreBlocks", ignoreBlocksDefault)
    settings.save(turtleStateFilename)
end

xSize = settings.get("xSize", 9)
ySize = settings.get("ySize", 9)
xPos = settings.get("xPos", 0)
yPos = settings.get("yPos", 0)
zPos = settings.get("zPos", 0)
firstRun = settings.get("firstRun", true)
aboveGround = settings.get("aboveGround", true)
isFacing = settings.get("isFacing", 0)
ignoreBlocks = settings.get("ignoreBlocks", ignoreBlocksDefault)

if xPos == 0 and yPos == 0 and zPos == 0 then
    print("I am already home")
else
    returnHome()
end

offLoad = function()
    moveDown()
    turnToDir(2)

    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end

    turnToDir(1)
    turtle.select(1)
    turtle.suck(64)

    moveUp()
    turnToDir(0)
end

buildMineCorner = function()
    moveForward()
    moveForward()
    turtle.digUp()
    turtle.digDown()
    moveForward()
    turtle.digUp()
    turtle.digDown()
    turnLeft()
    moveForward()
    turtle.digUp()
    turtle.digDown()
    moveForward()
    turtle.digUp()
    turtle.digDown()
    turnLeft()
    moveForward()
    turtle.digUp()
    turtle.digDown()
    moveForward()
    turtle.digUp()
    turtle.digDown()

    placeDownBlock("minecraft:cobblestone")
    placeUpBlock("minecraft:cobblestone")
    moveBackward()
    placeBlock("minecraft:cobblestone")

    placeDownBlock("minecraft:cobblestone")
    placeUpBlock("minecraft:cobblestone")
    moveBackward()
    placeBlock("minecraft:cobblestone")

    placeDownBlock("minecraft:cobblestone")
    placeUpBlock("minecraft:cobblestone")
    turnRight()
    moveBackward()
    placeBlock("minecraft:cobblestone")

    placeDownBlock("minecraft:cobblestone")
    placeUpBlock("minecraft:cobblestone")
    moveBackward()
    placeBlock("minecraft:cobblestone")

    placeDownBlock("minecraft:cobblestone")
    placeUpBlock("minecraft:cobblestone")
    turnRight()
    moveBackward()
    placeBlock("minecraft:cobblestone")

    moveBackward()
end

buildShaftWall = function(length, hasOreTunnels)

    if not hasOreTunnels and not type(hasOreTunnels) == "boolean" then
        hasOreTunnels = false -- Default value
    end

    for i=1,length do
        moveForward()

        turnLeft()

        moveForward()
        turtle.digUp()
        turtle.digDown()

        moveForward()
        turtle.digUp()
        turtle.digDown()

        if (math.fmod(xPos, 4) == -2 or math.fmod(xPos, 4) == 2) or (math.fmod(yPos, 4) == -2 or math.fmod(yPos, 4) == 2) then
            placeDownBlock("minecraft:stone")
            placeUpBlock("minecraft:stone")
            moveBackward()
            placeBlock("minecraft:stone")

            placeDownBlock("minecraft:stone")
            placeUpBlock("minecraft:stone")
            moveBackward()
            placeBlock("minecraft:stone")
        else

            placeUpBlock("minecraft:cobblestone")

            if hasOreTunnels then
                if ((isFacing == 1 or isFacing == 3) and math.fmod(xPos, 4) ~= 0) or ((isFacing == 0 or isFacing == 2) and math.fmod(yPos, 4) ~= 0) then 
                    placeDownBlock("minecraft:cobblestone")
                    moveBackward()
                    placeBlock("minecraft:cobblestone")
                else
                    moveBackward()
                end
            else 
                placeDownBlock("minecraft:cobblestone")
                moveBackward()
                placeBlock("minecraft:cobblestone") 
            end

            moveBackward()

        end

        turnRight()
    end
end

while true do
    local test = turtle.getFuelLevel()
    local solidBlockBelow = false

    print("Current fuel level: ", test)

    if firstRun then
        returnHome()

        for i=0,3 do

            turnToDir(i)

            for shaftStage = 7, 16 do

            if shaftStage == 0 then

                for i=0,16 do
                    turtle.dig()
                    moveForward()
                    if i >= 2 then
                        turtle.digUp()
                        turtle.digDown()
                    end
                end

                turnLeft()

                for i=0,14 do
                    turtle.dig()
                    moveForward()
                    turtle.digUp()
                    turtle.digDown()
                end

                turnRight()

                local hasSpace = true

                while true do
                
                        for items=1,15 do
                            if turtle.getItemCount(items) == 0 then
                                hasSpace = true
                                turtle.select(1)
                                break
                            else
                                hasSpace = false 
                            end
                        end

                        if not hasSpace then
                            local x = xPos
                            local y = yPos
                            local z = zPos
                            local f = isFacing

                            returnHome()
                            offLoad()
                            returnToPos(x,y,z,f)

                            hasSpace = true
                        end

                        if xPos >= (80 - 1) and yPos >= (16 - 1) then
                            returnHome()
                            break
                        end
                        
                        if xPos == (80 - 1) then
                            turnRight()
                            moveForward()
                            turtle.digUp()
                            turtle.digDown()
                            turnRight()
                        end
                        
                        if xPos == 17 and yPos ~= -15 then
                            turnLeft()
                            moveForward()
                            turtle.digUp()
                            turtle.digDown()
                            turnLeft()
                        end
                        
                        moveForward()
                        turtle.digUp()
                        turtle.digDown()

                        if xPos > 19 and xPos < 77 and yPos > -13 and yPos < 13 then
                            moveDown()
                            turtle.digDown()

                            if ((math.fmod(xPos, 4) == -2 or math.fmod(xPos, 4) == 2) and (math.fmod(yPos, 4) == -2 or math.fmod(yPos, 4) == 2)) or ((yPos == -12 or yPos == 12) and (math.fmod(xPos, 4) == -2 or math.fmod(xPos, 4) == 2)) or ((xPos == 20 or xPos == 76) and (math.fmod(yPos, 4) == -2 or math.fmod(yPos, 4) == 2)) then
                                placeDownBlock("druidcraft:fiery_torch")
                            end

                            moveUp()
                        end

                    
                end 
            elseif shaftStage == 1 then

                for i=0,1 do
                    turtle.dig()
                    moveForward()
                    if i >= 1 then
                        turtle.digUp()
                        turtle.digDown()
                    end
                end

                turnLeft()

                for i=0,1 do
                    turtle.dig()
                    moveForward()
                    turtle.digUp()
                    turtle.digDown()
                end

                turnRight()

                local test1 = 0

                while true do
                    if xPos >= (18 - 1) and yPos >= (3 - 1) then
                        break
                    end
                    
                    if xPos == (18 - 1) then
                        turnRight()
                        moveForward()
                        turtle.digUp()
                        turtle.digDown()
                        turnRight()
                    end
                    
                    if xPos == 2 and yPos ~= -2 then
                        turnLeft()
                        moveForward()
                        turtle.digUp()
                        turtle.digDown()
                        turnLeft()
                    end
                    
                    moveForward()
                    turtle.digUp()
                    turtle.digDown()
                end

                returnHome()

            elseif shaftStage == 3 then
                for i=0,1 do
                    moveForward()
                end

                turnLeft()

                for i=0,1 do
                    moveForward()
                end

                turnLeft()

                while true do
                    if not findItem("minecraft:stone") then
                        local x = xPos
                        local y = yPos
                        local z = zPos
                        local f = isFacing
        
                        returnHome()
        
                        while not findItem("minecraft:stone") do
                            print("Waiting for stone to be put in inventory.")
                            sleep(2)
                        end
        
                        returnToPos(x,y,z,f)
                    end

                    turtle.select(findItem("minecraft:stone"))

                    

                    if xPos >= (18 - 1) and yPos >= (3 - 1) then
                        break
                    end
                    
                    if xPos == (18 - 1) then
                        turnRight()
                        moveBackward()
                        turnRight()
                    end
                    
                    if xPos == 2 and yPos ~= -2 then
                        turnLeft()
                        if (yPos < -1 or yPos > 1) then
                            placeDownBlock("minecraft:stone")
                            placeUpBlock("minecraft:stone")
                            moveBackward()
                            placeBlock("minecraft:stone")
                        else
                            placeUpBlock("minecraft:stone")
                            moveBackward()
                        end
                        turnLeft()
                    end
                    
                    if xPos < (18 - 1) then
                        if (yPos < -1 or yPos > 1) then
                            placeDownBlock("minecraft:stone")
                            placeUpBlock("minecraft:stone")
                            moveBackward()
                            placeBlock("minecraft:stone")
                        else
                            placeUpBlock("minecraft:stone")
                            moveBackward()
                        end
                    else
                        moveBackward()
                    end
                end

                returnHome()

            elseif shaftStage == 4 then
                for i=0,16 do
                    moveForward()
                end

                turnLeft()

                for i=0,1 do
                    moveForward()
                end

                buildShaftWall(12)

                buildMineCorner()

                turnRight()

                buildShaftWall(61, true)

                buildMineCorner()

                turnRight()

                buildShaftWall(29)

                buildMineCorner()

                turnRight()

                buildShaftWall(61, true)

                buildMineCorner()

                turnRight()

                buildShaftWall(12)

                sleep(3)

                returnHome()

            elseif shaftStage == 5 then
                for i=1,18 do
                    moveForward()
                    
                    if math.fmod(xPos, 4) == 3 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                        turnRight()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnLeft()
                    end
                end

                turnLeft()

                for i=1,14 do
                    moveForward()

                    if math.fmod(yPos, 4) == -2 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                    end  
                end

                turtle.dig()
                placeBlock("druidcraft:fiery_torch")
                turnRight()

                for i=1,60 do
                    moveForward()

                    if math.fmod(xPos, 4) == 2 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                    end  
                end

                turtle.dig()
                placeBlock("druidcraft:fiery_torch")
                turnRight()

                for i=1,28 do
                    moveForward()

                    if math.fmod(yPos, 4) == -2 or math.fmod(yPos, 4) == 2 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                    end  
                end

                turtle.dig()
                placeBlock("druidcraft:fiery_torch")
                turnRight()

                for i=1,60 do
                    moveForward()

                    if math.fmod(xPos, 4) == 2 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                    end  
                end

                turtle.dig()
                placeBlock("druidcraft:fiery_torch")
                turnRight()

                for i=1,14 do
                    moveForward()

                    if math.fmod(yPos, 4) == 2 then
                        turnLeft()
                        turtle.dig()
                        placeBlock("druidcraft:fiery_torch")
                        turnRight()
                    end  
                end

                returnHome()
            elseif shaftStage == 6 then
                for i=1,78 do
                    if i >= 18 and math.fmod(xPos, 4) == 0 then
                        local calcYMoveNeg = -1 * xPos
                        local calcYMovePos = xPos
                        turnToDir(3)
                        while yPos >= calcYMoveNeg do
                            moveForward()
                        end
                        turtle.digDown()
                        moveDown()
                        turnToDir(1)
                        while yPos <= calcYMovePos do
                            moveForward()
                            if yPos == 0 then
                                while zPos ~= 0 do
                                    if zPos > 0 then
                                        turtle.digDown()
                                        moveDown()
                                    elseif zPos < 0 then
                                        turtle.digUp()
                                        moveUp()
                                    end
                                end
                            end
                        end
                        turtle.digDown()
                        moveDown()
                        turnToDir(3)
                        while yPos ~= 0 do
                            if yPos > 0 then
                                turnToDir(3)
                                moveForward()
                            elseif yPos < 0 then
                                turnToDir(1)
                                moveForward()
                            end
                        end

                        while zPos ~= 0 do
                            if zPos > 0 then
                                turtle.digDown()
                                moveDown()
                            elseif zPos < 0 then
                                turtle.digUp()
                                moveUp()
                            end
                        end

                        turnToDir(0)
                       
                    end
                    moveForward()
                end
                returnHome()

            end
        end
            exit()

            returnHome()

        end
    else

    if test <= 80 then
        returnHome()
        break
    end

    if xPos >= (xSize - 1) and yPos >= (ySize - 1) then
        returnHome()
    end
    
    if xPos == (xSize - 1) then
        turnRight()
        moveForward()
        turnRight()
    end
    
    if xPos == 0 and yPos ~= 0 then
        turnLeft()
        moveForward()
        turnLeft()
    end
    
    moveForward()
   
    if (math.fmod(xPos, 5) == 4 or math.fmod(xPos, 5) == -1) and (math.fmod(yPos, 5) == 4 or math.fmod(yPos, 5) == -1) then
        print("water here")
        turtle.digDown()
    else
        print("dirt here")
    end

    

    end

    print("Current xCoord: ", xPos)
    print("Current yCoord: ", yPos)

    sleep(1)

    
end
