--[[
TheNexusAvenger
Adorns a 3D model to a frame.
GitHub: https://github.com/TheNexusAvenger/Module3D



Module3D.new(Model): Module3D
    Creates a Model3D object.
Module3D:Attach3D(Frame: Frame, Model: BasePart | Model): Module3D
    Attaches a model or part to a frame. Returns a Model3D object.
    Does not use a clone of the model so it can be referenced directly.



Model3D object (extends ViewportFrame):
    Model3D.Object3D: Model - the model for the bounding box. If the input model was a model, it will be the same as the input.
    Model3D.AdornFrame: ViewportCFrame - the frame the model is adorned to.
    Model3D.Camera: Camera - the camera used by the viewport frame.
        [Derecated; use Model3D.CurrentCamera]
    
    Model3D:Update(): ()
        Force updates the camera CFrame.
    Model3D:SetActive(Active: boolean): ()
        [Deprecated, use Model3D.Visible]
        Sets the frame being active.
    Model3D:GetActive(): boolean
        [Deprecated, use Model3D.Visible]
        Reutrns if the frame is active.
    Model3D:SetCFrame(NewCFrame: CFrame): ()
        Sets the CFrame offset.
        Automatically updates the camera CFrame.
    Model3D:GetCFrame(): CFrame
        Returns the CFrame offset.
    Model3D:SetDepthMultiplier(Multiplier: number): ()
        Sets the multiplier for how far back the camera should go.
        Automatically updates the camera CFrame.
    Model3D:GetDepthMultiplier(): number
        Returns the depth multiplier
    Model3D:End(): ()
        [Deprecated, use Model3D:Destroy()]
        Destroys the frame and unparents the model.
--]]
--!strict

--Position to move the part/model to. Used to ensure the physics don't interact with the game.
local FAR_POSITION = Vector3.new(0, 10000, 0)



local Module3D = {}
Module3D.__index = Module3D

export type Module3D = {
    new: (ModelOrPart: BasePart | Model) -> Module3D,

    Object3D: Model,
    AdornFrame: ViewportFrame,
    Camera: Camera,
    Update: (self: Module3D) -> (),
    SetActive: (self: Module3D, Active: boolean) -> (),
    GetActive: (self: Module3D) -> (boolean),
    SetCFrame: (self: Module3D, NewCFrame: CFrame) -> (),
    GetCFrame: (self: Module3D) -> CFrame,
    SetDepthMultiplier: (self: Module3D, Multiplier: number) -> (),
    GetDepthMultiplier: (self: Module3D) -> (number),
    Destroy: (self: Module3D) -> (),
    End: (self: Module3D) -> (),
} & ViewportFrame



--[[
Creates a Model3D object.
--]]
function Module3D.new(ModelOrPart: BasePart | Model): Module3D
    local self = {
        CFrameOffset = CFrame.new(),
        DepthMultiplier = 1,
    }
    self.Object3D = ModelOrPart :: Model
    
    --If the model is a BasePart, make it a model.
    if ModelOrPart:IsA("BasePart") then
        local NewModel = Instance.new("Model")
        NewModel.Name = "Model3D"
        ModelOrPart.Parent = NewModel
        NewModel.PrimaryPart = ModelOrPart
        
        self.Object3D = NewModel
    end
    local Model = self.Object3D :: Model
    
    --Create the viewport frame.
    local ViewportFrame = Instance.new("ViewportFrame")
    ViewportFrame.BackgroundTransparency = 1
    self.AdornFrame = ViewportFrame
    
    --Create the camera.
    local Camera = Instance.new("Camera")
    Camera.Parent = ViewportFrame
    ViewportFrame.CurrentCamera = Camera
    
    --Set up the model.
    local BasePrimaryPart = Model.PrimaryPart
    if not BasePrimaryPart then
        Model.PrimaryPart = Model:FindFirstChildWhichIsA("BasePart",true)
    end
    
    --If a primary part exists, move the model.
    if Model.PrimaryPart then
        Model:PivotTo(CFrame.new(FAR_POSITION - Model.PrimaryPart.Position) * Model.PrimaryPart.CFrame)
        Model.PrimaryPart = BasePrimaryPart
    end
    Model.Parent = ViewportFrame
    
    --Create and set the object metatable.
    local Metatable = {}
    setmetatable(self, Metatable)
    Metatable.__index = function(self, Index: string): any
        --Return the camera (deprecated property).
        if Index == "Camera" then
            warn("Module3D.Camera is deprecated. Use Module3D.CurrentCamera instead.")
            return ViewportFrame.CurrentCamera
        end
        
        --Return the object value.
        local ObjectValue = rawget(Module3D :: any, Index)
        if ObjectValue ~= nil then
            return ObjectValue
        end
        local ClassValue = rawget(Module3D :: any, Index)
        if ClassValue ~= nil then
            return ClassValue
        end
        
        --Return the frame's value.
        return (ViewportFrame :: any)[Index]
    end
    Metatable.__newindex = function(self, Index: string, NewValue: any)
        if rawget(self :: any, Index) ~= nil then
            return
        end
        (ViewportFrame :: any)[Index] = NewValue
    end
    
    self:UpdateCFrame()
    return (self :: any) :: Module3D
end

--[[
Updates the camera's CFrame.
--]]
function Module3D:UpdateCFrame()
    local BoundingCFrame,BoundingSize = self.Object3D:GetBoundingBox()
    local ModelCenter = BoundingCFrame.Position
    
    --Determine the distance back.
    local MaxSize = math.max(BoundingSize.X, BoundingSize.Y, BoundingSize.Z)
    local DistanceBack = ((MaxSize / math.tan(math.rad(self.CurrentCamera.FieldOfView)))) * self.DepthMultiplier
    local Center = CFrame.new(ModelCenter)
    self.CurrentCamera.CFrame = Center * self.CFrameOffset * CFrame.new(0, 0, (MaxSize / 2) + DistanceBack)
    self.CurrentCamera.Focus = Center
end

--[[
Force updates the camera CFrame.
--]]
function Module3D:Update(): ()
    self:UpdateCFrame()
end

--[[
Sets the frame being active.
--]]
function Module3D:SetActive(Active: boolean): ()
    warn("Module3D:SetActive(Active) is deprecated. Use Module3D.Visible instead.")
    self.AdornFrame.Visible = Active
end

--[[
Reutrns if the frame is active.
--]]
function Module3D:GetActive(): boolean
    warn("Module3D:GetActive() is deprecated. Use Module3D.Visible instead.")
    return self.AdornFrame.Visible
end

--[[
Sets the CFrame offset.
--]]
function Module3D:SetCFrame(NewCFrame: CFrame): ()
    self.CFrameOffset = NewCFrame
    self:UpdateCFrame()
end

--[[
Returns the CFrame offset.
--]]
function Module3D:GetCFrame(): CFrame
    return self.CFrameOffset
end

--[[
Sets the multiplier for how far back the camera should go.
--]]
function Module3D:SetDepthMultiplier(Multiplier: number): ()
    self.DepthMultiplier = Multiplier
    self:UpdateCFrame()
end

--[[
Returns the depth multiplier
--]]
function Module3D:GetDepthMultiplier(): number
    return self.DepthMultiplier
end

--[[
Destroys the frame and unparents the model.
--]]
function Module3D:Destroy(): ()
    self.AdornFrame:Destroy()
    self.Object3D:Destroy()
end

--[[
Destroys the frame and unparents the model.
--]]
function Module3D:End(): ()
    warn("Module3D:End() is deprecated. Use Module3D:Destroy() instead.")
    self:Destroy()
end

--[[
Adorns a 3D model to a frame.
Returns a Model3D object.
--]]
function Module3D:Attach3D(Frame: Frame, Model: BasePart | Model): Module3D
    --Create the Model3D object.
    local Model3D = Module3D.new(Model)
    Model3D.AnchorPoint = Vector2.new(0.5, 0.5)
    Model3D.Position = UDim2.new(0.5, 0, 0.5, 0)
    Model3D.Visible = false
    Model3D.Parent = Frame

    --[[
    Updates the frame size.
    --]]
    local function UpdateFrameSize()
        local AbsoluteSize = Frame.AbsoluteSize
        local MinSize = math.abs(math.min(AbsoluteSize.X, AbsoluteSize.Y)) 
        Model3D.AdornFrame.Size = UDim2.new(0, MinSize, 0, MinSize)
    end
    local FrameChanged = Frame.Changed:Connect(UpdateFrameSize)
    UpdateFrameSize()

    --Override the destroy method to disconnect the events.
    local BaseDestroy = Model3D.Destroy
    local function NewDestroy(self: Module3D)
        BaseDestroy(self)
        
        --Disconnect the resize event.
        if FrameChanged then
            FrameChanged:Disconnect()
            FrameChanged = nil :: any
        end
    end
    rawset(Model3D, "Destroy", NewDestroy)

    --Return the Model3D.
    return Model3D
end



return Module3D