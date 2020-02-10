---LuaPlayerBuiltEntityEventFilters
---Events.set_event_filter(defines.events.on_built_entity, {{filter = "name", name = "fast-inserter"}})
local Event = require 'utils.event' --- @dep utils.event
local station_name_changer = 
function(event)
    local enetety = event.created_entity 
    local name = enetety.name

    if name == "train-stop" then --only do the event if its a trainstop
        local boundingbox = enetety.bounding_box 
        -- expanded box for recourse search:
        local bounding2 = { {boundingbox.left_top.x -100 ,boundingbox.left_top.y -100}  , {boundingbox.right_bottom.x +100,boundingbox.right_bottom.y +100 } }
        --gets all resources in bounding_box2:
        local recoursec = game.surfaces[1].find_entities_filtered{area = bounding2, type = "resource"} 
        
        if #recoursec > 0 then -- save cpu time if their are no recourses in bounding_box2
            local closest_distance
            local px,py = boundingbox.left_top.x,boundingbox.left_top.y
            local recourse_closed

            --Check which recource is closest
            for i, item in ipairs(recoursec) do
                if not closest_distance then
                    recourse_closed = item
                    local dx, dy = px - item.bounding_box.left_top.x, py - item.bounding_box.left_top.y
                    closest_distance = (dx*dx)+(dy*dy)
                else 
                    local dx, dy = px - item.bounding_box.left_top.x, py - item.bounding_box.left_top.y
                    if   (dx*dx)+(dy*dy) < closest_distance then
                        closest_distance = (dx*dx)+(dy*dy)  
                        recourse_closed = item
                    end
                end
        
            end
            

            local item_name = recourse_closed.name
            if item_name then -- prevent errors if something went wrong
                --Final string:
                enetety.backer_name = string.format("[L] [img=item.%s] %s %s (%s)",item_name,item_name:gsub("^%l", string.upper):gsub('-',' '),enetety.backer_name,Angle( enetety ))
            end
        end
    end
end
--add func to robot and player build entities
Event.add(defines.events.on_built_entity,station_name_changer)
Event.add(defines.events.on_robot_built_entity,station_name_changer)

    
--Credit to Cooldude2606 for using his lua magic to make this function.
function Angle( enetety )
    local angle = math.atan2(enetety.position.y,enetety.position.x)/math.pi
    local directions = {
        ['W'] = -0.875,
        ['NW'] = -0.625,
        ['N'] = -0.375,
        ['NE'] = -0.125,
        ['E'] = 0.125,
        ['SE'] = 0.375,
        ['S'] = 0.625,
        ['SW'] = 0.875
    }
    for direction, requiredAngle in pairs(directions) do   
        if angle < requiredAngle then  
            return direction   
        end 
    end 
end
 