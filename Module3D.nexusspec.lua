--[[
TheNexusAvenger

Tests the Module3D module.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local Module3DUnitTest = NexusUnitTesting.UnitTest:Extend()
local Module3DAttach3DUnitTest = NexusUnitTesting.UnitTest:Extend()

local Module3D = require(script.Parent:WaitForChild("Module3D"))



--[[
Sets up the unit test.
--]]
function Module3DUnitTest:Setup()
	--Create the part.
	self.Part = Instance.new("Part")
	self.Part.Size = Vector3.new(4,4,4)
	
	--Create the component under testing.
	self.CuT = Module3D.new(self.Part)
end

--[[
Tests the constructor.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("Constructor"):SetRun(function(self)
	--Assert that the component under testing is set up correctly.
	self:AssertEquals(self.Part.Position,Vector3.new(0,10000,0),"Part wasn't moved.")
	self:AssertEquals(self.CuT.Object3D,self.Part.Parent,"Part wasn't enclosed in a part.")
	self:AssertEquals(self.CuT.BackgroundTransparency,1,"Background transparency is incorrect.")
	self:AssertEquals(self.CuT.CurrentCamera.CFrame,CFrame.new(0,10000,0) * CFrame.new(0,0,2 + (4/math.tan(math.rad(70)))),"Camera CFrame is incorrect.")
	
	--Create a component under testing with a model and assert it is set up correctly.
	local Model = Instance.new("Model")
	local Part1 = Instance.new("Part")
	Part1.Size = Vector3.new(2,2,2)
	Part1.CFrame = CFrame.new(-1,-1,-1)
	Part1.Parent = Model
	local Part2 = Instance.new("Part")
	Part2.Size = Vector3.new(2,2,2)
	Part2.CFrame = CFrame.new(1,1,1)
	Part2.Parent = Model
	local ModelCuT = Module3D.new(Model)
	self:AssertEquals(Part1.Position,Vector3.new(0,10000,0),"Part wasn't moved.")
	self:AssertEquals(Part2.Position,Vector3.new(2,10000 + 2,2),"Part wasn't moved.")
	self:AssertEquals(ModelCuT.Object3D,Model,"Model reference is incorrect.")
	self:AssertEquals(ModelCuT.BackgroundTransparency,1,"Background transparency is incorrect.")
	self:AssertEquals(ModelCuT.CurrentCamera.CFrame,CFrame.new(1,10001,1) * CFrame.new(0,0,2 + (4/math.tan(math.rad(70)))),"Camera CFrame is incorrect.")
end))

--[[
Tests setting values (metatable passthrough).
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SettingValues"):SetRun(function(self)
	--Set the properties of the component under testing directly.
	self.CuT.BorderSizePixel = 5
	self.CuT.BackgroundColor3 = Color3.new(0,0.5,1)
	
	--Assert the values are read correctly.
	self:AssertEquals(self.CuT.BorderSizePixel,5,"Value not read correctly.")
	self:AssertEquals(self.CuT.AdornFrame.BorderSizePixel,5,"Value was not set.")
	self:AssertEquals(self.CuT.BackgroundColor3,Color3.new(0,0.5,1),"Value not read correctly.")
	self:AssertEquals(self.CuT.AdornFrame.BackgroundColor3,Color3.new(0,0.5,1),"Value was not set.")
end))

--[[
Tests the Update method.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("Update"):SetRun(function(self)
	--Update the properties of the part and the camera.
	self.Part.CFrame = self.Part.CFrame * CFrame.new(0,2,0)
	self.Part.Size = Vector3.new(6,2,3)
	self.CuT.CurrentCamera.FieldOfView = 60
	
	--Update the CFrame and assert it is correct.
	self.CuT:Update()
	self:AssertEquals(self.CuT.CurrentCamera.CFrame,CFrame.new(0,10002,0) * CFrame.new(0,0,3 + (6/math.tan(math.rad(60)))),"Camera CFrame is incorrect.")
end))

--[[
Tests the SetActive and GetActive methods.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SetActive"):SetRun(function(self)
	--Set the component under testing as active and assert it is visible.
	self.CuT:SetActive(true)
	self:AssertTrue(self.CuT.Visible,"Frame isn't visible.")
	
	--Set the component under testing as inactive and assert it isn't visible.
	self.CuT:SetActive(false)
	self:AssertFalse(self.CuT.Visible,"Frame is visible.")
end))

--[[
Tests the SetCFrame and GetCFrame methods.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SetCFrame"):SetRun(function(self)
	--Set the CFrame and assert it was changed.
	self.CuT:SetCFrame(CFrame.new(1,2,3))
	self:AssertEquals(self.CuT:GetCFrame(),CFrame.new(1,2,3),"CFrame wasn't changed")
	self:AssertEquals(self.CuT.CurrentCamera.CFrame,CFrame.new(1,10002,3) * CFrame.new(0,0,2 + (4/math.tan(math.rad(70)))),"Camera CFrame is incorrect.")
end))

--[[
Tests the SetDepthMultiplier and GetDepthMultiplier methods.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SetDepthMultiplier"):SetRun(function(self)
	--Set the depth multiplier and assert it was changed.
	self.CuT:SetDepthMultiplier(2)
	self:AssertEquals(self.CuT:GetDepthMultiplier(),2,"Depth multiplier was not changed.")
	self:AssertEquals(self.CuT.CurrentCamera.CFrame,CFrame.new(0,10000,0) * CFrame.new(0,0,(2 + (4/math.tan(math.rad(70))) * 2)),"Camera CFrame is incorrect.")
end))

--[[
Tests the Destroy method.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SetDepthMultiplier"):SetRun(function(self)
	--Set the parent of the component under testing.
	local FrameParent = Instance.new("Frame")
	self.CuT.Parent = FrameParent
	self:AssertEquals(self.CuT.AdornFrame.Parent,FrameParent,"Parent was not set.")
	
	--Destroy the frame and assert the parents were cleared.
	self.CuT:Destroy()
	self:AssertNil(self.CuT.AdornFrame.Parent,"Adorn frame is still parented.")
	self:AssertNil(self.CuT.Object3D.Parent,"Model is still parented.")
end))

--[[
Tests the End method.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DUnitTest.new("SetDepthMultiplier"):SetRun(function(self)
	--Set the parent of the component under testing.
	local FrameParent = Instance.new("Frame")
	self.CuT.Parent = FrameParent
	self:AssertEquals(self.CuT.AdornFrame.Parent,FrameParent,"Parent was not set.")
	
	--Destroy the frame and assert the parents were cleared.
	self.CuT:End()
	self:AssertNil(self.CuT.AdornFrame.Parent,"Adorn frame is still parented.")
	self:AssertNil(self.CuT.Object3D.Parent,"Model is still parented.")
end))



--[[
Sets up the unit test.
--]]
function Module3DAttach3DUnitTest:Setup()
	--Create the part.
	self.Part = Instance.new("Part")
	self.Part.Size = Vector3.new(4,4,4)
	
	--Create the component under testing.
	self.ParentScreenGui = Instance.new("ScreenGui")
	self.ParentScreenGui.Parent = game:GetService("Lighting")
	self.ParentFrame = Instance.new("Frame")
	self.ParentFrame.Size = UDim2.new(0,100,0,100)
	self.ParentFrame.Parent = self.ParentScreenGui
	self.CuT = Module3D:Attach3D(self.ParentFrame,self.Part)
end

--[[
Tears down the unit test.
--]]
function Module3DAttach3DUnitTest:Teardown()
	--Destroy the resources.
	self.ParentScreenGui:Destroy()
	self.CuT:Destroy()
end

--[[
Tests the Attach3D method.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DAttach3DUnitTest.new("Attach3D"):SetRun(function(self)
	--Assert the component under testing is set up correctly.
	self:AssertEquals(self.CuT.AnchorPoint,Vector2.new(0.5,0.5),"Anchor point is not at the center.")
	self:AssertEquals(self.CuT.Position,UDim2.new(0.5,0,0.5,0),"Position is not at the center.")
	self:AssertEquals(self.CuT.Visible,false,"Model3D is active.")
	self:AssertEquals(self.CuT.Parent,self.ParentFrame,"Parent is not correct.")
	self:AssertEquals(self.CuT.Size,UDim2.new(0,100,0,100),"Size is not correct.")
	
	--Change the size of the parent and assert the frame size changes.
	self.ParentFrame.Size = UDim2.new(0,200,0,200)
	self:AssertEquals(self.CuT.Size,UDim2.new(0,200,0,200),"Size is not correct.")
	self.ParentFrame.Size = UDim2.new(0,200,0,100)
	self:AssertEquals(self.CuT.Size,UDim2.new(0,100,0,100),"Size is not correct.")
	self.ParentFrame.Size = UDim2.new(0,150,0,200)
	self:AssertEquals(self.CuT.Size,UDim2.new(0,150,0,150),"Size is not correct.")
end))

--[[
Tests the Destroy method with Attach3D.
--]]
NexusUnitTesting:RegisterUnitTest(Module3DAttach3DUnitTest.new("Attach3DDestroy"):SetRun(function(self)
	--Destroy the frame and assert the parents were cleared.
	self.CuT:Destroy()
	self:AssertNil(self.CuT.AdornFrame.Parent,"Adorn frame is still parented.")
	self:AssertNil(self.CuT.Object3D.Parent,"Model is still parented.")
	self:AssertEquals(self.ParentFrame.Parent,self.ParentScreenGui,"Base frame parent was changed.")
end))



return true