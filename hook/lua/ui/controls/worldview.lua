--******************************************************************************************************
--** Copyright (c) 2023  Willem 'Jip' Wijnia
--**
--** Permission is hereby granted, free of charge, to any person obtaining a copy
--** of this software and associated documentation files (the "Software"), to deal
--** in the Software without restriction, including without limitation the rights
--** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--** copies of the Software, and to permit persons to whom the Software is
--** furnished to do so, subject to the following conditions:
--**
--** The above copyright notice and this permission notice shall be included in all
--** copies or substantial portions of the Software.
--**
--** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--** SOFTWARE.
--******************************************************************************************************



do

    -- the following code was removed from the FAForever code base. The reason being that each time it runs it runs various computationally expensive functions
    -- that also generate a lot of garbage. And it does that each frame

    -- it was superseded with the 'Context based templates' feature. When assigned to 'tab', it allows for the same behavior that this UI mod gives you but
    -- without the performance problems

    ---@type 'only-tech1' | 'best-tech'
    local toggle = 'only-tech1'

    local oldWorldView = WorldView
    WorldView = ClassUI(oldWorldView) {
        HandleEvent = function(self, event)
            oldWorldView.HandleEvent(self, event)

            if (event.Type == 'MouseMotion') and (not CommandMode.GetCommandMode()[1] or self.AutoBuild) then
                local Units = GetSelectedUnits()
                if Units and not GetRolloverInfo() then
                    local BuildType = false
                    local MWP = GetMouseWorldPos()
                    local Deposits = GetDepositsAroundPoint(MWP.x, MWP.z, 0.8, 0)
                    if not table.empty(Deposits) then
                        if Deposits[1].Type == 1 then
                            BuildType = categories.MASSEXTRACTION
                        else
                            BuildType = categories.HYDROCARBON
                        end
                    end

                    if BuildType then
                        if self.AutoBuild and CommandMode.GetCommandMode()[2].name ~= self.AutoBuild then
                            self.AutoBuild = false
                        else
                            local _, _, BuildableCategories = GetUnitCommandData(Units)
                            BuildableCategories = BuildableCategories * BuildType
                            if toggle == 'only-tech1' then
                                BuildableCategories = BuildableCategories * categories.TECH1
                            else
                                local Techs = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2 }
                                for _, Tech in Techs do
                                    if not EntityCategoryEmpty(BuildableCategories * Tech) then
                                        BuildableCategories = BuildableCategories * Tech
                                        break
                                    end
                                end
                            end

                            local BuildBP = EntityCategoryGetUnitList(BuildableCategories)[1]
                            if BuildBP then
                                CommandMode.StartCommandMode('build', { name = BuildBP })
                                self.AutoBuild = BuildBP
                            end
                        end
                    else
                        CommandMode.EndCommandMode(true)
                        self.AutoBuild = false
                    end
                end
            end
        end,
    }
end
