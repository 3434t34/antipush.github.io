-- anti push v3

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local Connections = {}
local Joints = {
    "Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"
}

local function onCharacterAdded(Character)
    if Connections[Character] then
        Connections[Character]:Disconnect()
    end

    Connections[Character] = Services.RunService.Heartbeat:Connect(function()
        if not Character.Parent then
            Connections[Character]:Disconnect()
            Connections[Character] = nil
            return
        end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end

        local Ragdoll = Character:FindFirstChild("Ragdoll")
        if Ragdoll then
            Ragdoll:Destroy()

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local Torso = Character:FindFirstChild("Torso")

            if Humanoid and Torso then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid.PlatformStand = false

                for _, Motor in pairs(Torso:GetChildren()) do
                    if Motor:IsA("Motor6D") and table.find(Joints, Motor.Name) then
                        if Motor.Part0 == nil and Motor.Part1 then
                            local CacheAttachment1 = "CacheAttachment1" .. Motor.Name
                            local Attachment = HumanoidRootPart:FindFirstChild(CacheAttachment1)
                            if Attachment and Attachment.Parent then
                                Motor.Part0 = Attachment.Parent
                            end
                        end
                    end
                end

                for _, Descendant in pairs(Torso:GetDescendants()) do
                    if Descendant:IsA("BallSocketConstraint") and Descendant.Name:match("^SocketConstraint") then
                        Descendant.Enabled = false
                        Descendant.Parent = HumanoidRootPart
                    end
                end
                for _, Child in pairs(HumanoidRootPart:GetChildren()) do
                    if Child:IsA("BallSocketConstraint") and Child.Name:match("^SocketConstraint") then
                         Child.Enabled = false
                    end
                end

                for _, Part in pairs(Character:GetDescendants()) do
                    if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" then
                        local BoneCustom = Part:FindFirstChild("BoneCustom")
                        if BoneCustom then
                            BoneCustom.CanCollide = false
                            BoneCustom.Transparency = 1
                        end
                    end
                end

                local Stun = Character:FindFirstChild("Stun")
                if Stun then
                    Stun:Destroy()
                end

                local Rotate = Character:FindFirstChild("RotateDisabled")
                if Rotate then
                    Rotate:Destroy()
                end

            end
        end

        for _, Object in pairs(HumanoidRootPart:GetChildren()) do
            if Object:IsA("BodyVelocity") then
                Object:Destroy()
            end
        end

        local Magnitude = HumanoidRootPart.Velocity.Magnitude
        if Magnitude > 49 and Magnitude < 52 then
            if math.abs(HumanoidRootPart.Velocity.Y) < 5 then
                HumanoidRootPart.Velocity = Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
            end
        end
    end)
end

Player.CharacterAdded:Connect(onCharacterAdded)
if Player.Character then onCharacterAdded(Player.Character) end
