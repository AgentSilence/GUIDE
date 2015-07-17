term.redirect(term.native())
code = {}
curElement = 0
curColor = colors.green
 
term.clear()
 
function drawBox(x,y,endX,endY,color)
        for i=y > endY and endY or y,y > endY and y or endY do
                paintutils.drawLine(x,i,endX,i,color)
        end
end
 
function toColor(nColor)
        for i,v in pairs(colors) do
                if nColor == v then
                        return "colors."..i
                end
        end
end
 
function dualPull(...)
        local args={...}
        repeat
                local event = {os.pullEvent()}
                for i,v in pairs(args) do
                        if event[1] == v then
                                return unpack(event)
                        end
                end
        until false
end
 
function redraw()
        if #code > 0 then
        for i,v in pairs(code) do
                if curElement ~= i then
                        if v.class == "pixel" and v.visible == true then
                                paintutils.drawPixel(v.x,v.y,v.color)
                        elseif v.class == "line" and v.visible == true then
                                paintutils.drawLine(v.sX,v.sY,v.eX,v.eY,v.color)
                        elseif v.class == "text" and v.visible == true then
                                term.setCursorPos(v.x,v.y)
                                term.setTextColor(v.tColor)
                                term.setBackgroundColor(v.bColor)
                                term.write(v.text)
                        elseif v.class == "fill" and v.visible == true then
                                term.setBackgroundColor(v.color)
                                term.clear()
                        elseif v.class == "rectangle" and v.visible == true then
                                drawBox(v.sX,v.sY,v.eX,v.eY,v.color)
                        end
                elseif i == curElement then
                        if v.class == "pixel" then
                                paintutils.drawPixel(v.x,v.y,v.color ~= colors.blue and colors.blue or colors.lightBlue)
                        elseif v.class == "line" then
                                paintutils.drawLine(v.sX,v.sY,v.eX,v.eY,v.color ~= colors.blue and colors.blue or colors.lightBlue)
                        elseif v.class == "text" then
                                term.setCursorPos(v.x,v.y)
                                term.setTextColor(v.tColor ~= colors.blue and colors.blue or colors.lightBlue)
                                term.setBackgroundColor(v.bColor ~= colors.blue and colors.blue or colors.lightBlue)
                                term.write(v.text)
                        elseif v.class == "fill" then
                                term.setBackgroundColor(v.color ~= colors.blue and colors.blue or colors.lightBlue)
                                term.clear()
                        elseif v.class == "rectangle" then
                                drawBox(v.sX,v.sY,v.eX,v.eY,v.color ~= colors.blue and colors.blue or colors.lightBlue)
                        end
                end
        end
        end
end
 
function line(toX,toY,fromX,fromY,color,key)
        if toX == nil and toY == nil and fromX == nil and fromY == nil then
                event, button, fromX, fromY = os.pullEvent("mouse_click")
                event, button, toX, toY = os.pullEvent("mouse_click")
        end
        if not color then
                color = colors.red
        end
        local curPoint = "to"
        while true do
                redraw()
                paintutils.drawLine(fromX,fromY,toX,toY,color)
                paintutils.drawPixel(curPoint == "to" and toX or fromX,curPoint == "to" and toY or fromY,color ~= colors.lightBlue and colors.lightBlue or colors.blue)
                local event, button, x, y = dualPull("mouse_click","mouse_drag")
                if event == "mouse_drag" then
                        paintutils.drawLine(fromX,fromY,toX,toY,colors.black)
                        toX = curPoint == "to" and x or toX
                        toY = curPoint == "to" and y or toY
                        fromX = curPoint == "from" and x or fromX
                        fromY = curPoint == "from" and y or fromY
                        redraw()
                        paintutils.drawLine(fromX,fromY,toX,toY,color)
                elseif event == "mouse_click" then
                        if x == fromX and y == fromY and curPoint ~= "from" then
                                curPoint = "from"
                        elseif x == toX and y == toY and curPoint ~= "to" then
                                curPoint = "to"
                        elseif x == toX and y == toY and curPoint == "to" then
                                break
                        elseif x == fromX and y == fromY and curPont == "from" then
                                break
                        end
                end
        end
        local template = {
                class = "line",
                sX = fromX,
                sY = fromY,
                eX = toX,
                eY = toY,
                visible = true,
                color = color}
        if key then
                table.remove(code,key)
                table.insert(code,key,template)
        else
                table.insert(code,template)
        end
end
 
function text(x,y,sText,bColor,tColor,key)
        if not bColor and not tColor then
                tColor = colors.black
                bColor = colors.green
        end
        local tText = {}
        if sText then
                for i=1,#sText do
                        local letter = string.sub(sText,i,i)
                        table.insert(tText,letter)
                end
        end
        local selected = #tText
        if not x and not y then
                event, button, x, y = os.pullEvent("mouse_click")
        end
        repeat
                redraw()
                term.setCursorPos(x,y)
                term.setTextColor(tColor)
                term.setBackgroundColor(bColor)
                term.write(table.concat(tText))
                local event, key = dualPull("key","char")
                if event == "char" then
                        table.insert(tText,selected + 1,key)
                        selected = selected + 1
                elseif event == "key" then
                        if key == keys.left and selected > 0 then
                                selected = selected - 1
                        elseif key == keys.right and selected < #tText then
                                selected = selected + 1
                        elseif key == keys.backspace and selected > 0 then
                                local oldSel = selected
                                selected = selected - 1
                                table.remove(tText,oldSel)
                                paintutils.drawPixel(x + #tText,y,colors.black)
                        end
                end
        until key == keys.enter
        if #tText > 0 then
                local template = {
                        class = "text",
                        text = table.concat(tText),
                        x = x,
                        y = y,
                        tColor = tColor,
                        visible = true,
                        bColor = bColor}
                if key then
                        table.remove(code,key)
                        table.insert(code,key,template)
                else
                        table.insert(code,template)
                end
        end
end
 
function rectangle(fromX,fromY,toX,toY,color,key)
        paintutils.drawPixel(1,1,colors.green)
        if not fromX and not fromY and not toX and not toY then
                local event, button, fX, fY = os.pullEvent("mouse_click")
                fromX = fX
                fromY = fY
                local event, button, tX, tY = os.pullEvent("mouse_click")
                toX = tX
                toY = fY
        end
        if not color then
                color = colors.red
        end
        local curPoint = "to"
        while true do
                redraw()
                drawBox(fromX,fromY,toX,toY,color)
                paintutils.drawPixel(curPoint == "to" and toX or fromX, curPoint == "to" and toY or fromY, color ~= colors.lightBlue and colors.lightBlue or colors.blue)
                local event, button, x, y = dualPull("mouse_click","mouse_drag")
                if event == "mouse_drag" then
                        if curPoint == "to" then
                                drawBox(fromX,fromY,toX,toY,colors.black)
                                toX = x
                                toY = y
                        elseif curPoint == "from" then
                                drawBox(fromX,fromY,toX,toY,colors.black)
                                fromX = x
                                fromY = y
                        end
                elseif event == "mouse_click" then
                        if x == fromX and y == fromY and curPoint ~= "from" then
                                curPoint = "from"
                        elseif x == toX and y == toY and curPoint ~= "to" then
                                curPoint = "to"
                        elseif x == toX and y == toY and curPoint == "to" then
                                break
                        elseif x == fromX and y == fromY and curPont == "from" then
                                break
                        end
                end
        end
        local template = {
                class = "rectangle",
                sX = fromX < toX and fromX or toX,
                sY = fromY < toY and fromY or toY,
                eX = fromX > toX and fromX or toX,
                eY = fromY > toY and fromY or toY,
                visible = true,
                color = color}
        if key then
                table.remove(code,key)
                table.insert(code,key,template)
        else
                table.insert(code,template)
        end
end
 
function edit(key)
        local item = code[key]
        if item.class == "line" then
                line(item.sX,item.sY,item.eX,item.eY,item.color,key)
        elseif item.class == "text" then
                text(item.x,item.y,item.text,item.tColor,item.bColor,key)
        elseif item.class == "pixel" then
                 
        elseif item.class == "rectangle" then
                rectangle(item.sX,item.sY,item.eX,item.eY,item.color,key)
        end
end
 
function rightClickMenu(x,y)
        term.height, term.width = term.getSize()
        redraw()
        if y + 5 > term.height then
                y = y - 5
        end
        if x + 8 > term.width then
                x = x - (8 - (term.width-x))
        end
        drawBox(x,y,x+8,y+5,colors.white)
        term.setTextColor(colors.black)
        term.setCursorPos(x,y)
        term.write("Line")
        term.setCursorPos(x,y+1)
        term.write("Text")
        term.setCursorPos(x,y+2)
        term.write("Box")
        term.setCursorPos(x,y+3)
        term.write("Pixel")
        term.setCursorPos(x,y+4)
        term.write("Delete")
        local clickedInfo
        local clicked = false
        while true do
                drawBox(x,y,x+8,y+5,colors.white)
                term.setTextColor(colors.black)
                term.setCursorPos(x,y)
                term.write("Line")
                term.setCursorPos(x,y+1)
                term.write("Text")
                term.setCursorPos(x,y+2)
                term.write("Box")
                term.setCursorPos(x,y+3)
                term.write("Pixel")
                term.setCursorPos(x,y+4)
                term.write("Delete")
                local event, button, clickX, clickY = os.pullEvent("mouse_click")
                if button == 2 and (clickX > x+8 or clickX < x or clickY > y+5 or clickY < y) then
                        drawBox(x,y,x+8,y+5,colors.black)
                        redraw()
                        x = clickX
                        y = clickY
                        if y + 5 > term.height then
                                y = y - 5
                        end
                        if x + 8 > term.width then
                                x = x - (8 - (term.width-x))
                        end
                elseif button == 1 then
                        if clickX >= x and clickX < x + 9 and clickY == y then
                                drawBox(x,y,x+8,y+5,colors.black)
                                line()
                        end
                        if clickX >= x and clickX < x + 9 and clickY == y+1 then
                                drawBox(x,y,x+8,y+5,colors.black)
                                text()
                        end
                        if clickX >= x and clickX < x + 9 and clickY == y+2 then
                                drawBox(x,y,x+8,y+5,colors.black)
                                rectangle()
                        end
                        if clickX >= x and clickX < x + 9 and clickY == y+3 then
                                drawBox(x,y,x+8,y+5,colors.black)
                                pixel()
                        end
                        if clickX >= x and clickX < x + 9 and clickY == y+4 then
                                drawBox(x,y,x+8,y+5,colors.black)
                                table.remove(code)
                        end
                 
                        if clickX > x+8 or clickX < x then
                                clicked = true
                                clickInfo = {event, button, clickX, clickY}
                                break
                        end
                        if clickY > y+5 or clickY < y then
                                clicked = true
                                clickInfo = {event, button, clickX, clickY}
                                break
                        end
                end
        end
        if clicked == true then
                os.queueEvent(unpack(clickInfo))
        end
end
 
function save()
        local file = fs.open("test","a")
        local rect = false
        local currentBColor
        local currentTColor
        file.writeLine("function drawGUI()")
        for i,v in pairs(code) do
                if v.class == "rectangle" then
                        if not paintutils.drawFilledBox and not rect then
                                file.writeLine([[
local function drawBox(x,y,endX,endY,color)
        for i=y > endY and endY or y,y > endY and y or endY do
                paintutils.drawLine(x,i,endX,i,color)
        end    
end]])
                                rect = true
                        end
                        file.writeLine(rect and "       drawBox("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")" or "       paintutils.drawFilledBox("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")")
                        currentTColor = v.color
                        currentBColor = v.color
                elseif v.class == "line" then
                        file.writeLine("        paintutils.drawLine("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")")
                        currentTColor = v.color
                        currentBColor = v.color
                elseif v.class == "text" then
                        file.writeLine("        term.setCursorPos("..v.x..","..v.y..")")
                        if currentTColor ~= v.tColor then
                                file.writeLine("        term.setTextColor("..toColor(v.tColor)..")")
                                currentTColor = v.tColor
                        end
                        if currentBColor ~= v.bColor then
                                file.writeLine("        term.setBackgroundColor("..toColor(v.bColor)..")")
                                currentBColor = v.bColor
                        end
                        file.writeLine('        term.write("'..v.text..'")')
                elseif v.class == "pixel" then
                        file.writeLine(" ")
                        file.writeLine("        paintutils.drawPixel("..x..","..y..","..color..")")
                        currentTColor = v.color
                        currentBColor = v.color
                end
        end
        file.writeLine("end")
        file.close()
end
