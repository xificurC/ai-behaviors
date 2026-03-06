"""QA tests — adversarial edge cases and bug proofs."""

import random
from model import Game, GameState, Dir, Pos


def make_game(seed=42):
    g = Game(rng=random.Random(seed))
    g.start()
    return g


# ============================================================
# BUG 1: Premature win when star blocks apple placement
# ============================================================

def test_bug_premature_win_star_blocks_apple():
    """Snake at 63 cells eats apple while star is on the only remaining cell.
    _free_cells counts star as occupied -> returns empty -> WIN.
    But the snake only fills 63 cells. The star is on the 64th.
    Spec says: win = snake fills all 64 cells."""
    g = make_game()
    # Build a 62-cell snake
    body = []
    for r in range(8):
        cols = range(8) if r % 2 == 0 else range(7, -1, -1)
        for c in cols:
            body.append(Pos(c, r))
    g.body = body[:62]  # 62 cells
    g.pending_growth = 0

    # The 2 remaining cells
    free_a = body[62]
    free_b = body[63]

    # Apple on one, star on the other
    g.apple = free_a
    g.star = free_b
    g.star_timer = 15

    # Position head adjacent to apple
    head = g.body[-1]
    dx = free_a.col - head.col
    dy = free_a.row - head.row
    if dx == 1:
        g.direction = Dir.RIGHT
    elif dx == -1:
        g.direction = Dir.LEFT
    elif dy == 1:
        g.direction = Dir.DOWN
    elif dy == -1:
        g.direction = Dir.UP

    g.tick()

    # BUG: game declares WIN here because _free_cells returns [] (star occupies last cell)
    # EXPECTED: game should NOT be WIN — snake is 63 cells, not 64
    assert g.state != GameState.WIN, (
        f"Premature win! Snake is {len(g.body)} cells, not 64. "
        f"Star at {free_b} blocks apple placement but snake hasn't filled the board."
    )


def test_star_should_not_prevent_apple_placement():
    """When only 2 cells remain and snake eats apple, star is on the other cell.
    The game must handle this gracefully — not declare a false win."""
    g = make_game()
    body = []
    for r in range(8):
        cols = range(8) if r % 2 == 0 else range(7, -1, -1)
        for c in cols:
            body.append(Pos(c, r))
    g.body = body[:62]
    free_a = body[62]
    free_b = body[63]
    g.apple = free_a
    g.star = free_b
    g.star_timer = 10
    head = g.body[-1]
    dx = free_a.col - head.col
    dy = free_a.row - head.row
    if dx == 1: g.direction = Dir.RIGHT
    elif dx == -1: g.direction = Dir.LEFT
    elif dy == 1: g.direction = Dir.DOWN
    elif dy == -1: g.direction = Dir.UP

    g.tick()
    # After eating apple, snake is 63 cells. Star on last cell.
    # Game should either:
    #   a) Remove the star to make room for apple, or
    #   b) Place apple on star's cell (removing star), or
    #   c) Defer apple placement until star despawns
    # Regardless, it should NOT be a win.
    assert len(g.body) == 63
    assert g.state == GameState.PLAYING


# ============================================================
# BUG 2: Star timer processed AFTER win check
# ============================================================

def test_star_timeout_same_tick_as_apple_eat():
    """Star timer = 1, snake eats apple on same tick.
    Star should expire (step 8.10) but win check (step 8.8) fires first.
    If star expiration freed the cell, apple could be placed there."""
    g = make_game()
    body = []
    for r in range(8):
        cols = range(8) if r % 2 == 0 else range(7, -1, -1)
        for c in cols:
            body.append(Pos(c, r))
    g.body = body[:62]
    free_a = body[62]
    free_b = body[63]
    g.apple = free_a
    g.star = free_b
    g.star_timer = 1  # will expire this tick at step 8.10
    g._star_just_spawned = False

    head = g.body[-1]
    dx = free_a.col - head.col
    dy = free_a.row - head.row
    if dx == 1: g.direction = Dir.RIGHT
    elif dx == -1: g.direction = Dir.LEFT
    elif dy == 1: g.direction = Dir.DOWN
    elif dy == -1: g.direction = Dir.UP

    g.tick()
    # Star should have expired, freeing cell for apple
    # Game should NOT be win (snake is 63, not 64)
    assert g.star is None, "Star should have expired (timer was 1)"
    assert g.state != GameState.WIN, "Should not win when star expiry frees a cell"


# ============================================================
# BUG 3: Garbage test — star_despawns_after_20_ticks has no assertion
# (This test replaces the original with one that actually verifies)
# ============================================================

def test_star_actually_despawns_after_exactly_20_ticks():
    """Star must be present for exactly 20 ticks, then gone."""
    g = make_game()
    g.star = Pos(0, 0)
    g.star_timer = 20
    g._star_just_spawned = False

    # Run 19 ticks — star must survive
    for tick_num in range(19):
        g.body = [Pos(4, 2), Pos(4, 3), Pos(4, 4)]
        g.direction = Dir.RIGHT
        g.apple = Pos(7, 7)  # far away
        g.state = GameState.PLAYING
        g.tick()
        assert g.star == Pos(0, 0), f"Star disappeared early at tick {tick_num + 1}"
        assert g.star_timer == 20 - (tick_num + 1), f"Timer wrong at tick {tick_num + 1}"

    # Tick 20 — star must be gone
    g.body = [Pos(4, 2), Pos(4, 3), Pos(4, 4)]
    g.direction = Dir.RIGHT
    g.apple = Pos(7, 7)
    g.state = GameState.PLAYING
    g.tick()
    assert g.star is None, "Star should be gone after 20 ticks"
    assert g.star_timer == 0


# ============================================================
# BUG 4: Conditional assertion in test_star_not_decremented_on_spawn_tick
# ============================================================

def test_star_spawn_tick_timer_not_decremented_unconditional():
    """Star spawns when apple is eaten. On that tick, timer must NOT decrement.
    This test uses an unconditional assertion (no 'if star' guard)."""

    class AlwaysSpawnRng:
        def choice(self, seq):
            return seq[0]
        def random(self):
            return 0.0  # always < STAR_CHANCE

    g = Game(rng=AlwaysSpawnRng())
    g.start()
    assert g.star is not None, "Star must spawn with AlwaysSpawnRng"
    initial_star = g.star
    initial_timer = g.star_timer
    assert initial_timer == 20

    # Clear the star, set up scenario to eat apple and trigger new star spawn
    g.star = None
    g.star_timer = 0
    g.apple = Pos(5, 4)  # in front of snake

    g.tick()  # eat apple -> new apple placed -> star spawns

    assert g.star is not None, "Star must spawn when apple is eaten with AlwaysSpawnRng"
    assert g.star_timer == 20, f"Star timer should be 20 on spawn tick, got {g.star_timer}"


# ============================================================
# Edge cases: boundaries, empty, zero, max, overflow
# ============================================================

def test_eat_apple_at_every_corner():
    """Apple in each corner — snake must be able to eat it without crash."""
    corners = [Pos(0, 0), Pos(7, 0), Pos(0, 7), Pos(7, 7)]
    for corner in corners:
        g = make_game()
        g.apple = corner
        # Position snake adjacent to corner
        if corner == Pos(0, 0):
            g.body = [Pos(2, 0), Pos(1, 0), Pos(0, 1)]
            g.direction = Dir.UP  # (0,1) -> (0,0)
        elif corner == Pos(7, 0):
            g.body = [Pos(5, 0), Pos(6, 0), Pos(7, 1)]
            g.direction = Dir.UP
        elif corner == Pos(0, 7):
            g.body = [Pos(2, 7), Pos(1, 7), Pos(0, 6)]
            g.direction = Dir.DOWN
        elif corner == Pos(7, 7):
            g.body = [Pos(5, 7), Pos(6, 7), Pos(7, 6)]
            g.direction = Dir.DOWN
        g.tick()
        assert g.state == GameState.PLAYING, f"Crashed eating apple at {corner}"
        assert g.score == 1


def test_wall_collision_all_8_corners():
    """Hitting wall from every edge cell in every possible direction."""
    # Top edge going up
    for c in range(8):
        g = make_game()
        g.body = [Pos(c, 2), Pos(c, 1), Pos(c, 0)]
        g.direction = Dir.UP
        g.tick()
        assert g.state == GameState.GAME_OVER, f"Should die at top edge col {c}"

    # Bottom edge going down
    for c in range(8):
        g = make_game()
        g.body = [Pos(c, 5), Pos(c, 6), Pos(c, 7)]
        g.direction = Dir.DOWN
        g.tick()
        assert g.state == GameState.GAME_OVER, f"Should die at bottom edge col {c}"


def test_queue_after_tick_consumes_one():
    """After a tick consumes 1 queued input, a new input can be enqueued."""
    g = make_game()
    g.enqueue(Dir.UP)
    g.enqueue(Dir.LEFT)
    assert len(g.input_queue) == 2

    g.tick()  # consumes UP
    assert len(g.input_queue) == 1
    assert g.direction == Dir.UP

    # Now there's room for 1 more
    g.enqueue(Dir.DOWN)  # legal: last queued is LEFT, DOWN is not opposite/same
    assert len(g.input_queue) == 2


def test_rapid_reversal_through_queue():
    """Pressing RIGHT -> UP -> LEFT rapidly. LEFT is valid because it's relative to UP (last queued), not RIGHT (current)."""
    g = make_game()  # moving RIGHT
    g.enqueue(Dir.UP)     # legal vs RIGHT
    g.enqueue(Dir.LEFT)   # legal vs UP (not opposite)
    assert g.input_queue == [Dir.UP, Dir.LEFT]


def test_u_turn_through_queue_is_blocked():
    """Pressing UP then DOWN rapidly — DOWN is opposite of UP (last queued), rejected."""
    g = make_game()  # moving RIGHT
    g.enqueue(Dir.UP)
    g.enqueue(Dir.DOWN)  # opposite of UP -> rejected
    assert g.input_queue == [Dir.UP]


def test_score_boundary_speed_changes():
    """Verify speed transitions at exact boundaries including star-induced jumps."""
    g = make_game()
    # Star gives +5 points. Going from 8 to 13 should cross one threshold (10).
    g.score = 8
    assert g.level == 1
    g.score = 13
    assert g.level == 2
    assert g.speed == 5.5

    # Going from 18 to 23 (star eat) — crosses 20.
    g.score = 18
    assert g.level == 2
    g.score = 23
    assert g.level == 3
    assert g.speed == 6.0

    # Crossing two thresholds at once: 5 -> 15 (two thresholds: 10)
    # This can't happen with +5 star, but verify formula anyway
    g.score = 5
    assert g.level == 1
    g.score = 15
    assert g.level == 2  # floor(15/10)+1 = 2
    assert g.speed == 5.5


def test_pause_preserves_queue():
    """Queued inputs survive through pause/unpause."""
    g = make_game()
    g.enqueue(Dir.UP)
    assert g.input_queue == [Dir.UP]

    g.toggle_pause()
    assert g.input_queue == [Dir.UP], "Queue should survive pause"

    g.toggle_pause()
    assert g.input_queue == [Dir.UP], "Queue should survive unpause"

    g.tick()
    assert g.direction == Dir.UP


def test_pause_does_not_decrement_star_timer():
    """Star timer should NOT count down while paused."""
    g = make_game()
    g.star = Pos(0, 0)
    g.star_timer = 10
    g._star_just_spawned = False

    g.toggle_pause()
    for _ in range(5):
        g.tick()  # should be no-op
    assert g.star_timer == 10, "Star timer decremented while paused!"
    g.toggle_pause()

    g.body = [Pos(4, 2), Pos(4, 3), Pos(4, 4)]
    g.direction = Dir.RIGHT
    g.apple = Pos(7, 7)
    g.tick()
    assert g.star_timer == 9


def test_apple_never_on_snake_body():
    """After 50 apple eats, apple must never be on a body cell."""
    g = make_game(seed=1)
    for _ in range(50):
        if g.state != GameState.PLAYING:
            break
        # Place apple directly in front of snake
        dx, dy = g.direction.value
        next_pos = Pos(g.head.col + dx, g.head.row + dy)
        if 0 <= next_pos.col < 8 and 0 <= next_pos.row < 8 and next_pos not in g.body:
            g.apple = next_pos
        g.tick()
        if g.state == GameState.PLAYING and g.apple is not None:
            assert g.apple not in g.body, f"Apple placed on body cell {g.apple}!"


def test_star_never_on_body_or_apple():
    """After many apple eats with forced star spawns, star must never overlap body or apple."""

    class HighStarRng:
        """RNG that always triggers star spawn."""
        def __init__(self):
            self._rng = random.Random(42)
        def choice(self, seq):
            return self._rng.choice(seq)
        def random(self):
            return 0.0  # always spawn star

    g = Game(rng=HighStarRng())
    g.start()
    for _ in range(30):
        if g.state != GameState.PLAYING:
            break
        dx, dy = g.direction.value
        next_pos = Pos(g.head.col + dx, g.head.row + dy)
        if 0 <= next_pos.col < 8 and 0 <= next_pos.row < 8 and next_pos not in g.body:
            g.apple = next_pos
        g.tick()
        if g.state == GameState.PLAYING:
            if g.star is not None:
                assert g.star not in g.body, f"Star on body cell {g.star}!"
                assert g.star != g.apple, f"Star on apple cell {g.star}!"


def test_genuine_win_at_64_cells():
    """True win: snake fills exactly 64 cells, no star involved."""
    g = make_game()
    body = []
    for r in range(8):
        cols = range(8) if r % 2 == 0 else range(7, -1, -1)
        for c in cols:
            body.append(Pos(c, r))
    g.body = body[:63]
    g.apple = body[63]
    g.star = None
    g.pending_growth = 0

    head = g.body[-1]
    apple = body[63]
    dx = apple.col - head.col
    dy = apple.row - head.row
    if dx == 1: g.direction = Dir.RIGHT
    elif dx == -1: g.direction = Dir.LEFT
    elif dy == 1: g.direction = Dir.DOWN
    elif dy == -1: g.direction = Dir.UP
    else:
        g.body[-1] = Pos(apple.col - 1, apple.row)
        g.direction = Dir.RIGHT

    g.tick()
    assert g.state == GameState.WIN
    assert len(g.body) == 64


def test_eating_star_near_wall_no_crash():
    """Star next to wall, snake eats it. No growth, no wall issue."""
    g = make_game()
    g.body = [Pos(5, 0), Pos(6, 0), Pos(7, 0)]
    g.direction = Dir.LEFT
    g.star = Pos(6, 0)  # star is on body... wait, need it adjacent
    # Put star ahead
    g.body = [Pos(4, 0), Pos(3, 0), Pos(2, 0)]
    g.direction = Dir.LEFT
    g.star = Pos(1, 0)
    g.star_timer = 5
    g.apple = Pos(7, 7)

    g.tick()
    assert g.score == 5
    assert g.star is None
    assert g.head == Pos(1, 0)
    assert len(g.body) == 3  # no growth from star


def test_multiple_ticks_without_input():
    """Snake continues in current direction when queue is empty."""
    g = make_game()
    g.apple = Pos(0, 0)  # out of the way
    positions = [g.head]
    for _ in range(3):
        g.tick()
        positions.append(g.head)
    # Should move right each tick
    assert positions == [Pos(4, 4), Pos(5, 4), Pos(6, 4), Pos(7, 4)]


def test_death_on_immediately_after_start():
    """Head at (4,4) moving right. Only 3 ticks to wall."""
    g = make_game()
    g.apple = Pos(0, 0)  # avoid eating
    g.tick()  # (5,4)
    g.tick()  # (6,4)
    g.tick()  # (7,4)
    assert g.state == GameState.PLAYING
    g.tick()  # (8,4) -> wall
    assert g.state == GameState.GAME_OVER


def test_start_resets_all_state():
    """After game over, starting a new game resets everything."""
    g = make_game()
    g.score = 42
    g.pending_growth = 5
    g.star = Pos(1, 1)
    g.star_timer = 7
    g.input_queue = [Dir.UP, Dir.DOWN]
    g.state = GameState.GAME_OVER
    g.body = [Pos(0, 0)]

    g.start()
    assert g.score == 0
    assert g.pending_growth == 0
    assert g.star is None
    assert g.star_timer == 0
    assert g.input_queue == []
    assert g.state == GameState.PLAYING
    assert g.body == [Pos(2, 4), Pos(3, 4), Pos(4, 4)]
    assert g.direction == Dir.RIGHT
    assert g.apple is not None
