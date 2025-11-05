-- Fast fuzzy matching algorithm with scoring
local M = {}

-- Character scoring weights
local SEQUENTIAL_BONUS = 15        -- bonus for adjacent matches
local SEPARATOR_BONUS = 30         -- bonus for matches after path separators
local CAMEL_BONUS = 30             -- bonus for matches on camelCase boundaries
local FIRST_LETTER_BONUS = 15      -- bonus for matching first letter
local LEADING_LETTER_PENALTY = -5  -- penalty for every letter before first match
local MAX_LEADING_PENALTY = -15    -- maximum penalty for leading letters
local UNMATCHED_PENALTY = -1       -- penalty for unmatched characters

-- Check if character is a path separator
local function is_separator(char)
	return char == "/" or char == "\\" or char == "-" or char == "_" or char == " "
end

-- Check if character is uppercase (for camelCase detection)
local function is_upper(char)
	return char:match("%u") ~= nil
end

-- Fuzzy match with scoring
-- Returns: score (number), positions (table of match indices)
function M.match(text, pattern)
	if pattern == "" then
		return 100, {}
	end

	text = text:lower()
	pattern = pattern:lower()

	local text_len = #text
	local pattern_len = #pattern

	-- Quick check: all pattern chars must exist in text
	local pattern_idx = 1
	for i = 1, text_len do
		if text:sub(i, i) == pattern:sub(pattern_idx, pattern_idx) then
			pattern_idx = pattern_idx + 1
			if pattern_idx > pattern_len then
				break
			end
		end
	end

	if pattern_idx <= pattern_len then
		return 0, {}  -- Not all pattern characters found
	end

	-- Dynamic programming approach for best match
	local score = 0
	local positions = {}
	local pattern_idx = 1
	local prev_match_idx = 0
	local leading_letters = 0

	for i = 1, text_len do
		if pattern_idx > pattern_len then
			break
		end

		local text_char = text:sub(i, i)
		local pattern_char = pattern:sub(pattern_idx, pattern_idx)

		if text_char == pattern_char then
			table.insert(positions, i)

			-- Calculate bonus for this match
			local bonus = 0

			-- First letter bonus
			if i == 1 then
				bonus = bonus + FIRST_LETTER_BONUS
			end

			-- Sequential bonus (matching adjacent characters)
			if prev_match_idx > 0 and i == prev_match_idx + 1 then
				bonus = bonus + SEQUENTIAL_BONUS
			end

			-- Separator bonus
			if i > 1 and is_separator(text:sub(i - 1, i - 1)) then
				bonus = bonus + SEPARATOR_BONUS
			end

			-- CamelCase bonus
			if i > 1 and is_upper(text:sub(i, i)) and not is_upper(text:sub(i - 1, i - 1)) then
				bonus = bonus + CAMEL_BONUS
			end

			-- Apply leading letter penalty (only for first match)
			if pattern_idx == 1 then
				local penalty = math.max(LEADING_LETTER_PENALTY * leading_letters, MAX_LEADING_PENALTY)
				bonus = bonus + penalty
			end

			score = score + 100 + bonus
			prev_match_idx = i
			pattern_idx = pattern_idx + 1
		else
			-- Penalty for unmatched character
			if pattern_idx == 1 then
				leading_letters = leading_letters + 1
			end
			score = score + UNMATCHED_PENALTY
		end
	end

	-- Normalize score based on match quality
	local match_ratio = pattern_len / text_len
	score = score * (1 + match_ratio)

	return score, positions
end

-- Filter and sort items by fuzzy match score
-- items: array of strings
-- pattern: search pattern
-- Returns: sorted array of {text, score, positions}
function M.filter(items, pattern)
	if pattern == "" then
		local results = {}
		for _, item in ipairs(items) do
			table.insert(results, {
				text = item,
				score = 100,
				positions = {}
			})
		end
		return results
	end

	local results = {}

	for _, item in ipairs(items) do
		local score, positions = M.match(item, pattern)
		if score > 0 then
			table.insert(results, {
				text = item,
				score = score,
				positions = positions
			})
		end
	end

	-- Sort by score (descending)
	table.sort(results, function(a, b)
		return a.score > b.score
	end)

	return results
end

return M
