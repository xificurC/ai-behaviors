# Output Examples

Subfolders showcase how some of the hashtags influence the output of the LLM. Each has the same base prompt shown below. The folder names represent the hashtags added to the prompt. 3 special cases - `_` adds nothing, `nucleus` uses [the nucleus prompt](https://github.com/michaelwhitford/nucleus), and `bashes` uses [the BASHES dialectic prompt](https://levelup.gitconnected.com/the-dialectic-prompt-when-friction-helped-turn-my-ai-from-coding-assistant-to-my-software-brain-151ccc62b0e3).

Also see AI_comparison.md for an AI review with tables and such.

# Base prompt

Implement a snake game clone in python3 with pygame. Use venv to create a virtual environment. Rules of the game
- board is 8x8
- snake starts size 3 in the middle, moving right
- there's always an apple on the board; eating it grows the snake by 1
- occasionally a star spawns; eating it grows the snake by 3; if uneaten the star disappears after 20 turns; there's only at most 1 star present at every point
- the speed of the game increases after every 10 points
- the user can see the current points and speed
- the snake moves with wasd or arrow keys
- the game starts pressing enter; on game end enter starts a new game
- there's no leaderboard or persistence
- key presses stack - e.g. if the user presses "wd" rapidly (faster than game speed) the snake will turn up on first turn, right on second
- self collision is not allowed - turning left when moving right is impossible; this applies to stacked moves as well
- the game starts through a `snake` executable
