--[[
Script to add new store category(s) in the mod view

Author:		Ifko[nator]
Date:		21.01.2019
Version:	2.0

History:	V 1.0 @ 16.11.2015 - initial release in FS 15
			V 1.1 @ 09.12.2015 - bug fix for wrong placement of the new category in the mod view
			V 1.5 @ 25.10.2016 - add support for the new categories from FS 17
			V 1.8 @ 27.11.2017 - some improvements in the script, now it is smaller
			V 2.0 @ 21.01.2019 - add support for the new store from FS 19
]]

AddStoreCategory = {};

AddStoreCategory.currentModDirectory = g_currentModDirectory;
AddStoreCategory.debugPriority = 0;

local function printError(errorMessage, isWarning, isInfo)
	local prefix = "::ERROR:: ";
	
	if isWarning then
		prefix = "::WARNING:: ";
	elseif isInfo then
		prefix = "::INFO:: ";
	end;
	
	print(prefix .. "from the AddStoreCategory.lua: " .. tostring(errorMessage));
end;

local function printDebug(debugMessage, priority, addString)
	if AddStoreCategory.debugPriority >= priority then
		local prefix = "";
		
		if addString then
			prefix = "::DEBUG:: from the AddStoreCategory.lua: ";
		end;
		
		print(prefix .. tostring(debugMessage));
	end;
end;

local function addCategory()
    printDebug("Run initSpecialization.", 1, true);
	
	local modDesc = loadXMLFile("modDesc", AddStoreCategory.currentModDirectory .. "modDesc.xml");
	
	AddStoreCategory.debugPriority = Utils.getNoNil(getXMLFloat(modDesc, "modDesc.storeItems.newStoreCategories#debugPriority"), AddStoreCategory.debugPriority);
	
	local categoryNumber = 0;
	
	local supportedCategoryTypes = {
		"VEHICLE",
		"TOOL",
		"PLACEABLE",
		"OBJECT"
	};
	
	while true do
		local categoryKey = "modDesc.storeItems.newStoreCategories.newStoreCategory(" .. tostring(categoryNumber) .. ")";
		
		if not hasXMLProperty(modDesc, categoryKey) then
			break;
		end;
		
		local newCategoryName = getXMLString(modDesc, categoryKey .. "#name");
		
		if newCategoryName ~= nil  then
			newCategoryTitle = Utils.getNoNil(getXMLString(modDesc, categoryKey .. "#title"), newCategoryName);
			newCategoryType = Utils.getNoNil(string.upper(getXMLString(modDesc, categoryKey .. "#type")), "VEHICLE");
			newCategoryImage = Utils.getNoNil(getXMLString(modDesc, categoryKey .. "#image"), "imageNotDefined");
			
			local function getIsValidCategoryType(categoryType)
				for _, supportedCategoryType in pairs(supportedCategoryTypes) do
					if categoryType == supportedCategoryType then
						return true;
					end;
				end;
				
				return false;
			end;
			
			if getIsValidCategoryType(newCategoryType) then		
				if string.find(newCategoryImage, ".png") then
					newCategoryImage = string.sub(newCategoryImage, 1, string.len(newCategoryImage) - 3) .. "dds";
				end;
				
				newCategoryImageToCheck = newCategoryImage;
				
				if string.sub(newCategoryTitle, 1, 6) == "$l10n_" then
					newCategoryTitle = g_i18n:getText(string.sub(newCategoryTitle, 7));
				elseif g_i18n:hasText(newCategoryTitle) then
					newCategoryTitle = g_i18n:getText(newCategoryTitle);
				end;
				
				if string.sub(newCategoryImage, 1, 1) == "$" then
					newCategoryImageToCheck = string.sub(newCategoryImage, 2);
				else
					newCategoryImageToCheck = Utils.getFilename(newCategoryImage, AddStoreCategory.currentModDirectory);
				end;
				
				if fileExists(newCategoryImageToCheck) then
					printDebug("Added category '" .. newCategoryName .. "' successfully!", 1, true);
					printDebug("Facts of category '" .. newCategoryName .. "':", 2, true);
					printDebug("    Title = '" .. newCategoryTitle .. "'.", 2, false);
					printDebug("    image filename = '" .. newCategoryImage .. "'.", 2, false);
					printDebug("    Type = '" .. newCategoryType .. "'.", 2, false);
					printDebug("", 2, false);
					
					g_storeManager:addCategory(newCategoryName, newCategoryTitle, newCategoryImage, newCategoryType, AddStoreCategory.currentModDirectory);
				else
					if newCategoryImage == "imageNotDefined" then
						printError("No image for the category '" .. newCategoryName .. "' defined! This category will be NOT added!", false, false);
					else
						printError("Failed to load '" .. newCategoryImageToCheck .. "'! The category '" .. newCategoryName .. "' will be NOT added!", false, false);
					end;
				end;
			else
				printError("The category type '" .. newCategoryType .. "' are not exists! Set the Type to 'VEHICLE', 'TOOL', 'PLACEABLE' or 'OBJECT' instead! The category '" .. newCategoryName .. "' will be NOT added!", false, false);
			end;
		else
			printError("Missing the category name for category " .. categoryNumber	.. "! This category will be NOT added!", false, false);
		end;
		
		categoryNumber = categoryNumber + 1;
	end;
end;

Vehicle.init = Utils.appendedFunction(Vehicle.init, addCategory);