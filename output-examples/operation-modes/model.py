"""Snake game model. Pure logic, no rendering."""

import random
from enum import Enum
from typing import NamedTuple


class Dir(Enum):
    UP = (0, -1)
    DOWN = (0, 1)
    LEFT = (-1, 0)
    RIGHT = (1, 0)


OPPOSITES = {Dir.UP: Dir.DOWN, Dir.DOWN: Dir.UP, Dir.LEFT: Dir.RIGHT, Dir.RIGHT: Dir.LEFT}


class Pos(NamedTuple):
    col: int
    row: int


class GameState(Enum):
    START = "start"
    PLAYING = "playing"
    PAUSED = "paused"
    GAME_OVER = "game_over"
    WIN = "win"


class Game:
    BOARD_SIZE = 8
    STAR_CHANCE = 0.1
    STAR_TIMEOUT = 20
    STAR_WARN_TICKS = 5
    BASE_SPEED = 5.0
    SPEED_INCREMENT = 0.5
    SPEED_INTERVAL = 10
    MAX_QUEUE = 2

    def __init__(self, rng=None):
        self.rng = rng or random.Random()
        self.state = GameState.START
        self.score = 0
        self.direction = Dir.RIGHT
        self.body = [Pos(2, 4), Pos(3, 4), Pos(4, 4)]  # tail first, head last
        self.pending_growth = 0
        self.apple = None
        self.star = None
        self.star_timer = 0
        self.input_queue: list[Dir] = []
        self._star_just_spawned = False
        self.death_pos: Pos | None = None

    def start(self):
        self.state = GameState.PLAYING
        self.score = 0
        self.direction = Dir.RIGHT
        self.body = [Pos(2, 4), Pos(3, 4), Pos(4, 4)]
        self.pending_growth = 0
        self.apple = None
        self.star = None
        self.star_timer = 0
        self.input_queue.clear()
        self.death_pos = None
        self._place_apple()

    @property
    def head(self) -> Pos:
        return self.body[-1]

    @property
    def speed(self) -> float:
        return self.BASE_SPEED + (self.score // self.SPEED_INTERVAL) * self.SPEED_INCREMENT

    @property
    def level(self) -> int:
        return self.score // self.SPEED_INTERVAL + 1

    @property
    def tick_interval_ms(self) -> float:
        return 1000.0 / self.speed

    @property
    def star_is_warning(self) -> bool:
        return self.star is not None and self.star_timer <= self.STAR_WARN_TICKS

    def enqueue(self, direction: Dir):
        if self.state != GameState.PLAYING or len(self.input_queue) >= self.MAX_QUEUE:
            return
        last = self.input_queue[-1] if self.input_queue else self.direction
        if direction == last or direction == OPPOSITES[last]:
            return
        self.input_queue.append(direction)

    def tick(self) -> bool:
        """Advance one tick. Returns True if the game is still running."""
        if self.state != GameState.PLAYING:
            return False

        # 8.1: dequeue input
        if self.input_queue:
            self.direction = self.input_queue.pop(0)

        # 8.2: new head position
        dx, dy = self.direction.value
        new_head = Pos(self.head.col + dx, self.head.row + dy)

        # 8.3: wall check
        if not (0 <= new_head.col < self.BOARD_SIZE and 0 <= new_head.row < self.BOARD_SIZE):
            self.death_pos = new_head
            self.state = GameState.GAME_OVER
            return False

        # 8.4: self-collision check
        body_to_check = self.body if self.pending_growth > 0 else self.body[1:]  # exclude tail if it will retract
        if new_head in body_to_check:
            self.death_pos = new_head
            self.state = GameState.GAME_OVER
            return False

        # 8.5: move head
        self.body.append(new_head)

        # 8.6: eat check
        ate_apple = False
        if new_head == self.apple:
            self.score += 1
            self.pending_growth += 1
            ate_apple = True
        if new_head == self.star:
            self.score += 5
            self.star = None
            self.star_timer = 0

        # 8.7: growth
        if self.pending_growth > 0:
            self.pending_growth -= 1
        else:
            self.body.pop(0)

        # 8.10: star timer (before apple placement so expiring star frees its cell)
        if self.star is not None and not self._star_just_spawned:
            self.star_timer -= 1
            if self.star_timer <= 0:
                self.star = None
                self.star_timer = 0
        self._star_just_spawned = False

        # 8.8: apple placement
        if ate_apple:
            if len(self.body) == self.BOARD_SIZE ** 2:
                self.state = GameState.WIN
                return False
            # Remove star if it's blocking the only free cell
            if self.star is not None and not self._free_cells():
                self.star = None
                self.star_timer = 0
            self._place_apple()

        return True

    def _free_cells(self) -> list[Pos]:
        occupied = set(self.body)
        if self.apple is not None:
            occupied.add(self.apple)
        if self.star is not None:
            occupied.add(self.star)
        return [
            Pos(c, r)
            for r in range(self.BOARD_SIZE)
            for c in range(self.BOARD_SIZE)
            if Pos(c, r) not in occupied
        ]

    def _place_apple(self):
        free = self._free_cells()
        if not free:
            return
        self.apple = self.rng.choice(free)

        # star spawn chance
        self._star_just_spawned = False
        if self.star is None and self.rng.random() < self.STAR_CHANCE:
            star_free = [p for p in free if p != self.apple]
            if star_free:
                self.star = self.rng.choice(star_free)
                self.star_timer = self.STAR_TIMEOUT
                self._star_just_spawned = True

    def toggle_pause(self):
        if self.state == GameState.PLAYING:
            self.state = GameState.PAUSED
        elif self.state == GameState.PAUSED:
            self.state = GameState.PLAYING
