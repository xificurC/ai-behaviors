"""Tests for snake game model."""

import random
from model import Game, GameState, Dir, Pos, OPPOSITES


def make_game(seed=42):
    g = Game(rng=random.Random(seed))
    g.start()
    return g


# --- Initial state ---

def test_initial_snake_position():
    g = make_game()
    assert g.head == Pos(4, 4)
    assert g.body == [Pos(2, 4), Pos(3, 4), Pos(4, 4)]
    assert g.direction == Dir.RIGHT


def test_initial_score_and_speed():
    g = make_game()
    assert g.score == 0
    assert g.speed == 5.0
    assert g.level == 1


def test_apple_placed_on_start():
    g = make_game()
    assert g.apple is not None
    assert g.apple not in g.body


# --- Movement ---

def test_move_right():
    g = make_game()
    old_head = g.head
    g.tick()
    assert g.head == Pos(old_head.col + 1, old_head.row)
    assert len(g.body) == 3  # no growth


def test_move_all_directions():
    cases = [
        (Dir.UP, [Pos(4, 6), Pos(4, 5), Pos(4, 4)], Pos(4, 3)),
        (Dir.DOWN, [Pos(4, 2), Pos(4, 3), Pos(4, 4)], Pos(4, 5)),
        (Dir.LEFT, [Pos(6, 4), Pos(5, 4), Pos(4, 4)], Pos(3, 4)),
        (Dir.RIGHT, [Pos(2, 4), Pos(3, 4), Pos(4, 4)], Pos(5, 4)),
    ]
    for d, body, expected_head in cases:
        g = make_game()
        g.body = body
        g.direction = d
        g.apple = Pos(0, 0)  # out of the way
        g.tick()
        assert g.head == expected_head, f"Direction {d}: expected {expected_head}, got {g.head}"


# --- Wall collision ---

def test_wall_collision_right():
    g = make_game()
    g.body = [Pos(5, 4), Pos(6, 4), Pos(7, 4)]
    g.direction = Dir.RIGHT
    g.tick()
    assert g.state == GameState.GAME_OVER


def test_wall_collision_left():
    g = make_game()
    g.body = [Pos(2, 4), Pos(1, 4), Pos(0, 4)]
    g.direction = Dir.LEFT
    g.tick()
    assert g.state == GameState.GAME_OVER


def test_wall_collision_up():
    g = make_game()
    g.body = [Pos(4, 2), Pos(4, 1), Pos(4, 0)]
    g.direction = Dir.UP
    g.tick()
    assert g.state == GameState.GAME_OVER


def test_wall_collision_down():
    g = make_game()
    g.body = [Pos(4, 5), Pos(4, 6), Pos(4, 7)]
    g.direction = Dir.DOWN
    g.tick()
    assert g.state == GameState.GAME_OVER


# --- Self collision ---

def test_self_collision():
    g = make_game()
    # 5-cell snake in a shape where head hits mid-body (not tail)
    g.body = [Pos(2, 3), Pos(3, 3), Pos(4, 3), Pos(4, 4), Pos(3, 4)]
    g.direction = Dir.UP  # head at (3,4) going up -> (3,3) which is mid-body
    g.apple = Pos(0, 0)
    g.tick()
    assert g.state == GameState.GAME_OVER


def test_tail_chase_legal_when_not_growing():
    g = make_game()
    # snake in a U, head about to move to tail position
    g.body = [Pos(3, 3), Pos(4, 3), Pos(4, 4), Pos(3, 4)]
    g.pending_growth = 0
    g.direction = Dir.UP  # head at (3,4) going up -> (3,3) which is current tail
    # tail at (3,3) will retract, so (3,3) is legal
    g.tick()
    assert g.state == GameState.PLAYING
    assert g.head == Pos(3, 3)


def test_tail_chase_illegal_when_growing():
    g = make_game()
    g.body = [Pos(3, 3), Pos(4, 3), Pos(4, 4), Pos(3, 4)]
    g.pending_growth = 1  # growing, tail won't retract
    g.direction = Dir.UP  # head at (3,4) going up -> (3,3) which is tail (won't retract)
    g.tick()
    assert g.state == GameState.GAME_OVER


# --- Eating ---

def test_eat_apple():
    g = make_game()
    g.apple = Pos(5, 4)  # directly in front of snake
    g.tick()
    assert g.score == 1
    assert g.head == Pos(5, 4)
    assert len(g.body) == 4  # grew immediately: head added, tail not retracted


def test_eat_apple_new_apple_placed():
    g = make_game()
    g.apple = Pos(5, 4)
    g.tick()
    assert g.apple is not None
    assert g.apple != Pos(5, 4)  # new apple placed somewhere else
    assert g.apple not in g.body


def test_eat_star_gives_points_no_growth():
    g = make_game()
    g.star = Pos(5, 4)
    g.star_timer = 10
    initial_len = len(g.body)
    g.tick()
    assert g.score == 5
    assert g.star is None
    # next tick: no growth from star
    g.tick()
    assert len(g.body) == initial_len  # no growth


def test_growth_stacking():
    g = make_game()
    g.pending_growth = 2
    g.apple = Pos(5, 4)
    g.tick()  # eats apple, pending_growth was 2 -> decremented to 1, then +1 from apple = stays complex
    # after eating: pending_growth was 2, decremented to 1 in growth step, but apple added 1 before that
    # let me trace: eat check: pending_growth += 1 -> 3. growth step: pending_growth 3 -> 2, tail stays
    assert g.pending_growth == 2
    assert g.score == 1


# --- Input queue ---

def test_enqueue_valid():
    g = make_game()  # moving right
    g.enqueue(Dir.UP)
    assert g.input_queue == [Dir.UP]


def test_enqueue_reversal_rejected():
    g = make_game()  # moving right
    g.enqueue(Dir.LEFT)  # opposite of right
    assert g.input_queue == []


def test_enqueue_same_direction_rejected():
    g = make_game()  # moving right
    g.enqueue(Dir.RIGHT)  # same as current
    assert g.input_queue == []


def test_enqueue_max_depth():
    g = make_game()  # moving right
    g.enqueue(Dir.UP)
    g.enqueue(Dir.LEFT)  # legal: opposite of up? no, left is not opposite of up
    g.enqueue(Dir.DOWN)  # queue full (max 2)
    assert len(g.input_queue) == 2


def test_enqueue_checks_against_last_queued():
    g = make_game()  # moving right
    g.enqueue(Dir.UP)  # queued: [UP]
    g.enqueue(Dir.DOWN)  # opposite of last queued (UP) -> rejected
    assert g.input_queue == [Dir.UP]


def test_enqueue_same_as_last_queued_rejected():
    g = make_game()  # moving right
    g.enqueue(Dir.UP)
    g.enqueue(Dir.UP)  # same as last queued -> rejected
    assert g.input_queue == [Dir.UP]


def test_queued_inputs_consumed_one_per_tick():
    g = make_game()  # moving right, head at (4,4)
    g.enqueue(Dir.UP)
    g.enqueue(Dir.LEFT)
    g.tick()  # consumes UP
    assert g.direction == Dir.UP
    assert g.head == Pos(4, 3)
    g.tick()  # consumes LEFT
    assert g.direction == Dir.LEFT
    assert g.head == Pos(3, 3)


# --- Speed ---

def test_speed_increases_at_threshold():
    g = make_game()
    g.score = 9
    assert g.speed == 5.0
    g.score = 10
    assert g.speed == 5.5
    assert g.level == 2


def test_speed_formula():
    g = make_game()
    for pts, expected in [(0, 5.0), (9, 5.0), (10, 5.5), (19, 5.5), (20, 6.0), (61, 8.0)]:
        g.score = pts
        assert g.speed == expected, f"At {pts} pts: expected {expected}, got {g.speed}"


# --- Star lifecycle ---

def test_star_timer_decrements():
    g = make_game()
    g.star = Pos(0, 0)
    g.star_timer = 5
    g._star_just_spawned = False
    # ensure snake doesn't hit walls or star
    g.body = [Pos(4, 2), Pos(4, 3), Pos(4, 4)]
    g.direction = Dir.RIGHT
    g.tick()
    assert g.star_timer == 4


def test_star_removed_at_timer_zero():
    g = make_game()
    g.star = Pos(0, 0)
    g.star_timer = 1
    g._star_just_spawned = False
    g.body = [Pos(4, 2), Pos(4, 3), Pos(4, 4)]
    g.direction = Dir.RIGHT
    g.tick()
    assert g.star is None
    assert g.star_timer == 0


def test_star_warning_state():
    g = make_game()
    g.star = Pos(0, 0)
    g.star_timer = 6
    assert not g.star_is_warning
    g.star_timer = 5
    assert g.star_is_warning
    g.star_timer = 1
    assert g.star_is_warning


# --- Pause ---

def test_pause_toggle():
    g = make_game()
    assert g.state == GameState.PLAYING
    g.toggle_pause()
    assert g.state == GameState.PAUSED
    g.toggle_pause()
    assert g.state == GameState.PLAYING


def test_tick_does_nothing_when_paused():
    g = make_game()
    g.toggle_pause()
    old_head = g.head
    g.tick()
    assert g.head == old_head


def test_enqueue_rejected_when_paused():
    g = make_game()
    g.toggle_pause()
    g.enqueue(Dir.UP)
    assert g.input_queue == []


# --- Win condition ---

def test_win_when_board_full():
    g = make_game()
    # fill snake to 63 cells, apple at the one remaining cell
    body = []
    for r in range(8):
        for c in range(8):
            body.append(Pos(c, r))
    # keep 63 cells for body, 1 for apple
    g.body = body[:63]
    g.apple = body[63]
    g.pending_growth = 0
    g.direction = Dir.RIGHT
    g.star = None

    # position head so it can reach the apple
    # put head at the cell before apple
    apple = body[63]
    # set direction so head moves to apple
    head = g.body[-1]
    dx = apple.col - head.col
    dy = apple.row - head.row
    if dx == 1:
        g.direction = Dir.RIGHT
    elif dx == -1:
        g.direction = Dir.LEFT
    elif dy == 1:
        g.direction = Dir.DOWN
    elif dy == -1:
        g.direction = Dir.UP
    else:
        # apple not adjacent, manually fix
        g.body = body[:63]
        g.body[-1] = Pos(apple.col - 1, apple.row)
        g.direction = Dir.RIGHT

    g.tick()
    assert g.state == GameState.WIN
