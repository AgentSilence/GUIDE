code = {}
curElement = 999
curColor = colors.green

function redirectLoad()
  local count = 0
  repeat
    local tempFile = http.get("http://pastebin.com/raw.php?i=fU9Kj9zr")
    if tempFile then
      local tempCall = loadstring(tempFile.readAll())
      tempFile.close()
      tempCall()
    end
    count = count + 1
  until count == 5 or createRedirectBuffer
  if not createRedirectBuffer then
    error("Unable to directly load buffer after 5 tries",0)
  end
end

term.clear()
redirectLoad()

local redrawWin = createRedirectBuffer()


-- PAINTUTILS SNIPPETS --
function drawPixelInternal( xPos, yPos )
  redrawWin.setCursorPos( xPos, yPos )
  redrawWin.write(" ")
end

function drawPixel( xPos, yPos, nColour )
  if type( xPos ) ~= "number" or type( yPos ) ~= "number" or (nColour ~= nil and type( nColour ) ~= "number") then
    error( "Expected x, y, colour", 2 )
  end
  if nColour then
    redrawWin.setBackgroundColor( nColour )
  end
  drawPixelInternal( xPos, yPos )
end

function drawLine( startX, startY, endX, endY, nColour )
  if type( startX ) ~= "number" or type( startX ) ~= "number" or
    type( endX ) ~= "number" or type( endY ) ~= "number" or
    (nColour ~= nil and type( nColour ) ~= "number") then
    error( "Expected startX, startY, endX, endY, colour", 2 )
  end
  startX = math.floor(startX)
  startY = math.floor(startY)
  endX = math.floor(endX)
  endY = math.floor(endY)
  if nColour then
    redrawWin.setBackgroundColor( nColour )
  end
  if startX == endX and startY == endY then
    drawPixelInternal( startX, startY )
    return
  end
  local minX = math.min( startX, endX )
  if minX == startX then
    minY = startY
    maxX = endX
    maxY = endY
  else
    minY = endY
    maxX = startX
    maxY = startY
  end
  -- TODO: clip to screen rectangle?
  local xDiff = maxX - minX
  local yDiff = maxY - minY
  if xDiff > math.abs(yDiff) then
    local y = minY
    local dy = yDiff / xDiff
    for x=minX,maxX do
      drawPixelInternal( x, math.floor( y + 0.5 ) )
      y = y + dy
    end
  else
    local x = minX
    local dx = xDiff / yDiff
    if maxY >= minY then
      for y=minY,maxY do
        drawPixelInternal( math.floor( x + 0.5 ), y )
        x = x + dx
      end
    else
      for y=minY,maxY,-1 do
        drawPixelInternal( math.floor( x + 0.5 ), y )
        x = x - dx
      end
    end
  end
end
-- PAINTUTILS SNIPPETS --

function drawBox(x,y,endX,endY,color)
  for i=y > endY and endY or y,y > endY and y or endY do
    drawLine(x,i,endX,i,color)
  end
end

function drawNormBox(x,y,endX,endY,color)
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
  for i,v in pairs(code) do
  	if curElement ~= i then
      if v.class == "pixel" and v.visible == true then
        drawPixel(v.x,v.y,v.color)
      elseif v.class == "line" and v.visible == true then
        drawLine(v.sX,v.sY,v.eX,v.eY,v.color)
      elseif v.class == "text" and v.visible == true then
        redrawWin.setCursorPos(v.x,v.y)
        redrawWin.setTextColor(v.tColor)
        redrawWin.setBackgroundColor(v.bColor)
        redrawWin.write(v.text)
      elseif v.class == "fill" and v.visible == true then
       	redrawWin.setBackgroundColor(v.color)
       	redrawWin.clear()
      elseif v.class == "rectangle" and v.visible == true then
       	drawBox(v.sX,v.sY,v.eX,v.eY,v.color)
      end
    elseif i == curElement then
      if v.class == "pixel" then
        drawPixel(v.x,v.y,v.color ~= colors.blue and colors.blue or colors.lightBlue)
      elseif v.class == "line" then
        drawLine(v.sX,v.sY,v.eX,v.eY,v.color ~= colors.blue and colors.blue or colors.lightBlue)
      elseif v.class == "text" then
        redrawWin.setCursorPos(v.x,v.y)
        redrawWin.setTextColor(v.tColor ~= colors.blue and colors.blue or colors.lightBlue)
        redrawWin.setBackgroundColor(v.bColor ~= colors.blue and colors.blue or colors.lightBlue)
        redrawWin.write(v.text)
      elseif v.class == "fill" then
       	redrawWin.setBackgroundColor(v.color ~= colors.blue and colors.blue or colors.lightBlue)
       	redrawWin.clear()
      elseif v.class == "rectangle" then
      	drawBox(v.sX,v.sY,v.eX,v.eY,v.color ~= colors.blue and colors.blue or colors.lightBlue)
      end
    end
  end
  redrawWin.blit()
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
    drawNormBox(fromX,fromY,toX,toY,color)
    paintutils.drawPixel(curPoint == "to" and toX or fromX, curPoint == "to" and toY or fromY, color ~= colors.lightBlue and colors.lightBlue or colors.blue)
    local event, button, x, y = dualPull("mouse_click","mouse_drag")
    if event == "mouse_drag" then
      if curPoint == "to" then
      	drawNormBox(fromX,fromY,toX,toY,colors.black)
        toX = x
        toY = y
      elseif curPoint == "from" then
      	drawNormBox(fromX,fromY,toX,toY,colors.black)
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
  redraw()
  if y + 5 > redrawWin.height then
    y = y - 5
  end
  if x + 8 > redrawWin.width then
  	x = x - (8 - (redrawWin.width-x))
  end
  drawNormBox(x,y,x+8,y+5,colors.white)
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
  local clicked = false
  local clickInfo
  while true do
  	drawNormBox(x,y,x+8,y+5,colors.white)
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
      drawNormBox(x,y,x+8,y+5,colors.black)
      redraw()
      x = clickX
      y = clickY
      if y + 5 > redrawWin.height then
        y = y - 5
      end
      if x + 8 > redrawWin.width then
   	    x = x - (8 - (redrawWin.width-x))
      end
    elseif button == 1 then
      if clickX >= x and clickX < x + 9 and clickY == y then
        drawNormBox(x,y,x+8,y+5,colors.black)
        line()
      end
      if clickX >= x and clickX < x + 9 and clickY == y+1 then
        drawNormBox(x,y,x+8,y+5,colors.black)
        text()
      end
      if clickX >= x and clickX < x + 9 and clickY == y+2 then
        drawNormBox(x,y,x+8,y+5,colors.black)
        rectangle()
      end
      if clickX >= x and clickX < x + 9 and clickY == y+3 then
        drawNormBox(x,y,x+8,y+5,colors.black)
        pixel()
      end
      if clickX >= x and clickX < x + 9 and clickY == y+4 then
        drawNormBox(x,y,x+8,y+5,colors.black)
        table.remove(code)
        redraw()
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
      file.writeLine(rect and "  drawBox("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")" or "  paintutils.drawFilledBox("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")")
    elseif v.class == "line" then
      file.writeLine("  paintutils.drawLine("..v.sX..","..v.sY..","..v.eX..","..v.eY..","..toColor(v.color)..")")
    elseif v.class == "text" then
      file.writeLine("  term.setCursorPos("..v.x..","..v.y..")")
      file.writeLine("  term.setTextColor("..toColor(v.tColor)..")")
      file.writeLine("  term.setBackgroundColor("..toColor(v.bColor)..")")
      file.writeLine([[  term.write("]]..v.text..[[")]])
    elseif v.class == "pixel" then
      file.writeLine(" ")
      file.writeLine("  paintutils.drawPixel("..x..","..y..","..color..")")
    end
  end
  file.writeLine("end")
  file.close()
end
