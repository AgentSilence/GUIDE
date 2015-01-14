code = {}
curElement = 1 -- Placeholder
curColor = colors.red -- Placeholder

function dualPull(...)
  local e={...}
  local ev={os.pullEvent()}
  repeat
    for k,v in pairs(e) do
      if v==ev[1] then return unpack(ev) end
    end
    ev={os.pullEvent()}
  until false
end

function redraw()
  term.setBackgroundColor(colors.black)
  term.clear()
  for i,v in pairs(code) do
  	if curElement ~= i then
      if v.class == "pixel" then
        paintutils.drawPixel(v.x,v.y,v.color)
      elseif v.class == "line" then
        paintutils.drawLine(v.sX,v.sY,v.eX,v.eY,v.color)
      elseif v.class == "text" then
        term.setCursorPos(v.x,v.y)
        term.setTextColor(v.tColor)
        term.setBackgroundColor(v.bColor)
        term.write(v.text)
       elseif v.class == "fill" then
       	term.setBackgroundColor(v.color)
       	term.clear()
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
      end
    end
  end
end

function line(toX,toY,fromX,fromY)
  if not toX and not toY and not fromX and not fromY then
    event, button, fromX, fromY = os.pullEvent("mouse_click")
    event, button, toX, toY = os.pullEvent("mouse_click")
  end
  local curPoint = "to"
  while true do
  	redraw()
  	paintutils.drawLine(fromX,fromY,toX,toY,curColor)
  	paintutils.drawPixel(curPoint == "to" and toX or fromX,curPoint == "to" and toY or fromY,curColor ~= colors.red and colors.red or colors.blue)
    local event, button, x, y = dualPull("mouse_click","mouse_drag")
    if event == "mouse_drag" then
      toX = curPoint == "to" and x or toX
      toY = curPoint == "to" and y or toY
      fromX = curPoint == "from" and x or fromX
      fromY = curPoint == "from" and y or fromY
      paintutils.drawLine(fromX,fromY,toX,toY,curColor)
    elseif event == "mouse_click" then
      if x == fromX and y == fromY and curPoint ~= "from" then
        curPoint = "from"
        paintutils.drawPixel(curPoint == "to" and toX or fromX,curPoint == "to" and toY or fromY,curColor ~= colors.red and colors.red or colors.blue)
      elseif x == toX and y == toY and curPoint ~= "to" then
      	curPoint = "to"
      	paintutils.drawPixel(curPoint == "to" and toX or fromX,curPoint == "to" and toY or fromY,curColor ~= colors.red and colors.red or colors.blue)
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
  table.insert(code,template)
end
