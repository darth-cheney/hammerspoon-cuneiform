-- Load the signlist file
signDict = hs.json.read("~/signlist-processed.json")
local allChoices = {}

foo = nil

function getSyllableTextFor(aString, signCodes)
   local name = hs.styledtext.new(aString, {
                               ["font"] = {
                                  ["size"] = 24,
                                  ["color"] = "black"
                               }
   })
   
   local tmp_str = ""
   for i, code in ipairs(signCodes) do
      tmp_str = tmp_str .. string.format(" %x", code)
   end
   local unicodeStr = hs.styledtext.new(tmp_str, {["font"]={["size"]=12}})
   return name .. unicodeStr
end

function getSignTextFor(codes)
   local str = ""
   for idx, code in pairs(codes) do
      str = str .. utf8.char(code)
   end
   return hs.styledtext.new(str, {
                               ["font"] = {
                                  ["name"] = "SantakkuM",
                                  ["size"] = 48,
                                  ["color"] = "black"
                               }
   })
end

-- Helper function for sorting keys
-- alphabetically in a table
function pairsByKeys (t, f)
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, f)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
   end
   return iter
end

-- Focus the last used window.
local function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then lastFocused[1]:focus() end
end


for syllable, sign in pairs(signDict) do
   local thisChoice = {}
   thisChoice["subText"] = getSyllableTextFor(syllable, sign);
   thisChoice["text"] = getSignTextFor(sign);
   thisChoice["codes"] = sign
   table.insert(allChoices, thisChoice)
end

function choiceSort(a, b)
   return a["subText"] < b["subText"]
end


table.sort(allChoices, choiceSort)

chooser = hs.chooser.new(function(choice)
      if choice then
         local str = ""
         for idx, code in pairs(choice["codes"]) do
            str = str .. utf8.char(code)
         end
         hs.pasteboard.setContents(str)
         focusLastFocused()
         hs.eventtap.keyStrokes(hs.pasteboard.getContents())
      end
end
)

chooser:choices(allChoices)
chooser:searchSubText(true)


hs.hotkey.bind({"ctrl", "alt"}, "space", function() chooser:show() end)
