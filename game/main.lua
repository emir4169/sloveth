https = nil
local overlayStats = require("lib.overlayStats")
local runtimeLoader = require("runtime.loader")
local json = require("lib.json")
InputTypes = {
  LITERAL = 1,
  BOOLEAN = 2,
  VAR_OR_BLOCK = 3,
}
argTypes = {
  LITERAL = 1,
  VARIABLE = 2,
  BLOCK = 3,
  BOOLEAN = 4,
}
currentSprites = {
}
projectJson = ""
require("lib.batteries"):export()
function VariableJSONToObject(jsondata, varid)
  local variable = {}
  -- "`jEk@4|i[#Fk?(8x)AV.-my variable": [
  --     "my variable",
  --     0
  --   ]
  variable.name = jsondata[1] or "Variable"
  variable.value = jsondata[2] or 0
  variable.id = varid or "unknown"
  return variable
end
function inputJSONToObject(jsondata)
  local input = {}
  type = jsondata[1];
  inputValue = jsondata[2];
  --if(type == 1){
  --    parsedInput.inputType = ParsedInput::LITERAL;
  --    //std::cout << "doing it! " << inputValue.dump() << std::endl;
  --    parsedInput.literalValue = Value::fromJson(inputValue);
  --    //std::cout << "literal value = " << parsedInput.literalValue.asString();
  --} else if(type == 3){
  --    if(inputValue.is_array()){
  --        parsedInput.inputType = ParsedInput::VARIABLE;
  --        parsedInput.variableId = inputValue[2].get<std::string>();
  --    } else{
  --        parsedInput.inputType = ParsedInput::BLOCK;
  --        parsedInput.blockId = inputValue.get<std::string>();
  --    }
  --} else if(type == 2){
  --    parsedInput.inputType = ParsedInput::BOOLEAN;
  --    parsedInput.blockId = inputValue.get<std::string>();
  --}
  if type == InputTypes.LITERAL then
    input.inputType = InputTypes.LITERAL
    input.literalValue = jsondata[2] -- Assuming this is a value that can be directly used
  elseif type == InputTypes.VAR_OR_BLOCK then
    if type(inputValue) == "table" and inputValue[2] then
      input.inputType = InputTypes.VAR_OR_BLOCK
      input.argType = argTypes.VARIABLE
      input.variableId = inputValue[2] -- Assuming this is the variable ID
    else
      input.inputType = InputTypes.VAR_OR_BLOCK
      input.argType = argTypes.BLOCK
      input.blockId = inputValue -- Assuming this is the block ID
    end
  elseif type == InputTypes.BOOLEAN then
    input.inputType = InputTypes.BOOLEAN
    input.argType = argTypes.BOOLEAN
    input.blockId = inputValue -- Assuming this is the block ID for boolean
  else
  return input
end
function BlockJSONToObject(jsondata)
  local block = {}
  -- "q1tFN$*XDR3tZ4^8/4H8": {
  --   "opcode": "event_whenflagclicked",
  --   "next": "%w[,(b;K-k^:uqL8d#3|",
  --   "parent": null,
  --   "inputs": {},
  --   "fields": {},
  --   "shadow": false,
  --   "topLevel": true,
  --   "x": 879,
  --   "y": 250
  -- }
  block.opcode = jsondata.opcode or "we_fucked_up"
  block.next = jsondata.next or nil
  block.parent = jsondata.parent or nil
  block.inputs = jsondata.inputs or {}
  block.fields = jsondata.fields or {}
  block.shadow = jsondata.shadow or false
  block.topLevel = jsondata.topLevel or false
  if block.opcode == "we_fucked_up" then
    error("Block opcode is missing or invalid! What the Fuck Happened???")
  end
  return block
end
function SpriteJSONToObject(jsondata)
  local sprite = {}
 -- "isStage": true,
 -- "name": "Stage",
 -- "variables": {
 --   "`jEk@4|i[#Fk?(8x)AV.-my variable": [
 --     "my variable",
 --     0
 --   ]
 -- },
 -- "lists": {},
 -- "broadcasts": {},
 -- "blocks": {},
 -- "comments": {},
 -- "currentCostume": 0,
 -- "costumes": [
 --   {
 --     "name": "backdrop1",
 --     "dataFormat": "svg",
 --     "assetId": "cd21514d0531fdffb22204e0ec5ed84a",
 --     "md5ext": "cd21514d0531fdffb22204e0ec5ed84a.svg",
 --     "rotationCenterX": 240,
 --     "rotationCenterY": 180
 --   }

  sprite.isStage = jsondata.isStage or false
  sprite.name = jsondata.name or "Sprite"
  --sprite.variables = jsondata.variables or {}
  for index, value in ipairs(jsondata.variables) do
    if type(value) == "table" and value[1] and value[2] then
      jsondata.variables[index] = VariableJSONToObject(value, index)
    end
  end
  sprite.lists = jsondata.lists or {}
  sprite.broadcasts = jsondata.broadcasts or {}
  sprite.blocks = jsondata.blocks or {}
  sprite.comments = jsondata.comments or {}
  sprite.currentCostume = jsondata.currentCostume or 0
  sprite.costumes = jsondata.costumes or {}
  sprite.sounds = jsondata.sounds or {}
  sprite.volume = jsondata.volume or 100
  sprite.layerOrder = jsondata.layerOrder or 0
  sprite.visible = jsondata.visible or true
  sprite.x = jsondata.x or 0
  sprite.y = jsondata.y or 0
  sprite.size = jsondata.size or 100
  sprite.direction = jsondata.direction or 90
  sprite.draggable = jsondata.draggable or false
  sprite.rotationStyle = jsondata.rotationStyle or "all around"
  return sprite

end

function love.load()
  https = runtimeLoader.loadHTTPS()
  -- Your game load here
  -- get the json file from the project folder in the project
  local projectFile, ProjectFilesize = love.filesystem.read("project/project.json")
  if not projectFile then
    error("Project file not found!")
  end
  projectJson = json.decode(projectFile)


  overlayStats.load() -- Should always be called last
end

function love.draw()
  -- Your game draw here
  overlayStats.draw() -- Should always be called last
end

function love.update(dt)
  -- Your game update here
  overlayStats.update(dt) -- Should always be called last
end

function love.keypressed(key)
  if key == "escape" and love.system.getOS() ~= "Web" then
    love.event.quit()
  else
    overlayStats.handleKeyboard(key) -- Should always be called last
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  overlayStats.handleTouch(id, x, y, dx, dy, pressure) -- Should always be called last
end
