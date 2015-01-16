code = {}
curElement = 1
curColor = colors.red

function drawBox(x,y,endX,endY,color)
  for i=y > endY and endY or y,y > endY and y or endY do
    paintutils.drawLine(x,i,endX,i,color)
  end
end

function dualPull(...)
  local args={...}
  repeat
    local evnt = {os.pullEvent()}
    for i,v in pairs(args) do
      if evnt[1] == v then
      	return unpack(evnt)
      end
    end
  until false
end

function redraw()
  term.setBackgroundColor(colors.black)
  term.clear()
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
       	drawBox(v.x,v.y,v.endX,v.endY,v.color)
      end
    else
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

function line(toX,toY,fromX,fromY,color,key)
  if not toX and not toY and not fromX and not fromY then
    event, button, fromX, fromY = os.pullEvent("mouse_click")
    event, button, toX, toY = os.pullEvent("mouse_click")
  end
  if not color then
  	color = colors.red
  end
  local curPoint = "to"
  while true do
  	redraw()
  	paintutils.drawLine(fromX,fromY,toX,toY,curColor)
  	paintutils.drawPixel(curPoint == "to" and toX or fromX,curPoint == "to" and toY or fromY,color ~= colors.lightBlue and colors.lightBlue or colors.blue)
    local event, button, x, y = dualPull("mouse_click","mouse_drag")
    if event == "mouse_drag" then
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
    color = curColor}
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
    bColor = colors.red
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
    local event, button, x, y = os.pullEvent("mouse_click")
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
  if not fromX and not fromY and not toX and not toY then
    local event, button, x, y = os.pullEvent("mouse_click")
    fromX = x
    fromY = y
    local event, button, x, y = os.pullEvent("mouse_click")
    toX = x
    toY = y
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
        toX = x
        toY = y
      elseif curPoint == "from" then
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
    sX = fromX,
    sY = fromY,
    eX = toX,
    eY = toY,
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
  elseif code[key].class == "text" then
  	text(item.x,item.y,item.text,item.tColor,item.bColor,key)
  elseif code[key].class == "pixel" then
  	
  elseif code[key].class == "rectangle" then
  	rectangle(item.sX,item.sY,item.eX,item.eY,item.color,key)
  end
  code[key] = item
end
