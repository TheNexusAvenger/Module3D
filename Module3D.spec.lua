--[[
TheNexusAvenger

Tests the Module3D module.
--]]
--!strict

local Module3D = require(game:GetService("ReplicatedStorage"):WaitForChild("Module3D"))

return function()
    describe("A Module3D using new(BasePart)", function()
        local TestPart, TestModule3D = nil, nil
        beforeEach(function()
            TestPart = Instance.new("Part")
            TestPart.Size = Vector3.new(4, 4, 4)
            TestModule3D = Module3D.new(TestPart)
        end)
        afterEach(function()
            TestModule3D:Destroy()
        end)

        it("should set up the part.", function()
            expect(TestPart.Position).to.equal(Vector3.new(0, 10000, 0))
            expect(TestModule3D.Object3D).to.equal(TestPart.Parent)
            expect(TestModule3D.BackgroundTransparency).to.equal(1)
            expect(TestModule3D.CurrentCamera.CFrame).to.equal(CFrame.new(0, 10000, 0) * CFrame.new(0, 0, 2 + (4 / math.tan(math.rad(70)))))
        end)

        it("should pass values.", function()
            --Set the properties of the test frame directly.
            TestModule3D.BorderSizePixel = 5
            TestModule3D.BackgroundColor3 = Color3.new(0, 0.5, 1)
            
            --Assert the values are read correctly.
            expect(TestModule3D.BorderSizePixel).to.equal(5)
            expect(TestModule3D.AdornFrame.BorderSizePixel).to.equal(5)
            expect(TestModule3D.BackgroundColor3).to.equal(Color3.new(0, 0.5, 1))
            expect(TestModule3D.AdornFrame.BackgroundColor3).to.equal(Color3.new(0, 0.5, 1))
        end)

        it("should update the CFrame.", function()
            --Update the properties of the part and the camera.
            TestPart.CFrame = TestPart.CFrame * CFrame.new(0, 2, 0)
            TestPart.Size = Vector3.new(6, 2, 3)
            TestModule3D.CurrentCamera.FieldOfView = 60
            
            --Update the CFrame and assert it is correct.
            TestModule3D:Update()
            expect(TestModule3D.CurrentCamera.CFrame).to.equal(CFrame.new(0, 10002, 0) * CFrame.new(0, 0, 3 + (6 / math.tan(math.rad(60)))))
        end)

        it("should set the frame as active (deprecated).", function()
            --Set the test frame as active and assert it is visible.
            TestModule3D:SetActive(true)
            expect(TestModule3D.Visible).to.equal(true)
            expect(TestModule3D:GetActive()).to.equal(true)
            
            --Set the test frame as inactive and assert it isn't visible.
            TestModule3D:SetActive(false)
            expect(TestModule3D.Visible).to.equal(false)
            expect(TestModule3D:GetActive()).to.equal(false)
        end)

        it("should set the CFrame offset.", function()
            TestModule3D:SetCFrame(CFrame.new(1, 2, 3))
            expect(TestModule3D:GetCFrame()).to.equal(CFrame.new(1, 2, 3))
            expect(TestModule3D.CurrentCamera.CFrame).to.equal(CFrame.new(1, 10002, 3) * CFrame.new(0, 0, 2 + (4 / math.tan(math.rad(70)))))
        end)

        it("should set multipliers.", function()
            TestModule3D:SetDepthMultiplier(2)
            expect(TestModule3D:GetDepthMultiplier()).to.equal(2)
            expect(TestModule3D.CurrentCamera.CFrame).to.equal(CFrame.new(0, 10000, 0) * CFrame.new(0, 0, (2 + (4 / math.tan(math.rad(70))) * 2)))
        end)

        it("should destroy the frame.", function()
            --Set the parent of the test frame.
            local FrameParent = Instance.new("Frame")
            TestModule3D.Parent = FrameParent
            expect(TestModule3D.AdornFrame.Parent).to.equal(FrameParent)
            
            --Destroy the frame and assert the parents were cleared.
            TestModule3D:Destroy()
            expect(TestModule3D.AdornFrame.Parent).to.equal(nil)
            expect(TestModule3D.Object3D.Parent).to.equal(nil)
        end)

        it("should destroy the frame using End (deprecated).", function()
            --Set the parent of the test frame.
            local FrameParent = Instance.new("Frame")
            TestModule3D.Parent = FrameParent
            expect(TestModule3D.AdornFrame.Parent).to.equal(FrameParent)
            
            --Destroy the frame and assert the parents were cleared.
            TestModule3D:End()
            expect(TestModule3D.AdornFrame.Parent).to.equal(nil)
            expect(TestModule3D.Object3D.Parent).to.equal(nil)
        end)
    end)

    describe("A Module3D using new(Model)", function()
        it("should set up the model.", function()
            local Model = Instance.new("Model")
            local Part1 = Instance.new("Part")
            Part1.Size = Vector3.new(2, 2, 2)
            Part1.CFrame = CFrame.new(-1, -1, -1)
            Part1.Parent = Model

            local Part2 = Instance.new("Part")
            Part2.Size = Vector3.new(2, 2, 2)
            Part2.CFrame = CFrame.new(1, 1, 1)
            Part2.Parent = Model

            local TestModule3D = Module3D.new(Model)
            expect(Part1.Position).to.equal(Vector3.new(0, 10000, 0))
            expect(Part2.Position).to.equal(Vector3.new(2, 10000 + 2, 2))
            expect(TestModule3D.Object3D).to.equal(Model)
            expect(TestModule3D.BackgroundTransparency).to.equal(1)
            expect(TestModule3D.CurrentCamera.CFrame).to.equal(CFrame.new(1, 10001, 1) * CFrame.new(0, 0, 2 + (4 / math.tan(math.rad(70)))))
            TestModule3D:Destroy()
        end)
    end)

    describe("A Module3D using Attach3D", function()
        local TestPart, ParentScreenGui, ParentFrame, TestModule3D = nil, nil, nil, nil
        beforeEach(function()
            TestPart = Instance.new("Part")
            TestPart.Size = Vector3.new(4, 4, 4)
            TestModule3D = Module3D.new(TestPart)

            ParentScreenGui = Instance.new("ScreenGui")
            ParentScreenGui.Parent = game:GetService("Lighting")
            ParentFrame = Instance.new("Frame")
            ParentFrame.Size = UDim2.new(0,100,0,100)
            ParentFrame.Parent = ParentScreenGui
            TestModule3D = Module3D:Attach3D(ParentFrame, TestPart)
        end)
        afterEach(function()
            ParentScreenGui:Destroy()
            TestModule3D:Destroy()
        end)

        it("should set up the part.", function()
            --Assert the test frame is set up correctly.
            expect(TestModule3D.AnchorPoint).to.equal(Vector2.new(0.5, 0.5))
            expect(TestModule3D.Position).to.equal(UDim2.new(0.5, 0, 0.5, 0))
            expect(TestModule3D.Visible).to.equal(false)
            expect(TestModule3D.Parent).to.equal(ParentFrame)
            expect(TestModule3D.Size).to.equal(UDim2.new(0, 100, 0, 100))
            
            --Change the size of the parent and assert the frame size changes.
            ParentFrame.Size = UDim2.new(0, 200, 0, 200)
            task.wait()
            expect(TestModule3D.Size).to.equal(UDim2.new(0, 200, 0, 200))
            ParentFrame.Size = UDim2.new(0, 200, 0, 100)
            task.wait()
            expect(TestModule3D.Size).to.equal(UDim2.new(0, 100, 0, 100))
            ParentFrame.Size = UDim2.new(0, 150, 0, 200)
            task.wait()
            expect(TestModule3D.Size).to.equal(UDim2.new(0, 150, 0, 150))
        end)
    end)
end