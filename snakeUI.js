var SnakeUI = (function () {

  var Game = function (opts) {
    console.log(opts);
    this.board = new SnakeBoard(opts.dim, opts.numApples, opts.numWalls);
    this.dim = this.board.dim;
    this.createBoard();   
    this.setInterval(opts.timeStep);
    this.impulse = {x: 0, y: 0};
    this.IMPULSES = { "up": {x: -1, y: 0},
                      "down": {x: 1, y: 0},
                      "left": {x: 0, y: -1},
                      "right": {x: 0, y: 1} }
                      console.log(this.board.apples.length);
                      console.log(this.board.walls.length);
  }

  Game.prototype.setInterval = function (timeStep) {
    var that = this;

    this.interval = window.setInterval(function () {
        that.setImpulse.apply(that);
        that.makeMove(that.impulse);
        that.updateBoard();

        if (that.lose()) {
          that.loseAction();
        } else if (that.won()) {
          that.wonAction();
        }
    }, timeStep);
  }

  // Game.prototype.createCounter = function () {
  //   $("body").
  // }

  Game.prototype.validImpulse = function (impulse) {
    return this.board.isValidDir(impulse.x, impulse.y);
  }

  Game.prototype.validKeyPress = function (dir) {
    return key.isPressed(dir) && this.validImpulse(this.IMPULSES[dir]);
  }

  Game.prototype.setImpulse = function () {
    if (this.validKeyPress("up")) {
      this.impulse = this.IMPULSES.up; 
    } else if (this.validKeyPress("down")) {
      this.impulse = this.IMPULSES.down;
    } else if (this.validKeyPress("left")) {
      this.impulse = this.IMPULSES.left; 
    } else if (this.validKeyPress("right")) {
      this.impulse = this.IMPULSES.right; 
    }
  }

  Game.prototype.createBoard = function () {
    var that = this;

    $("body").append($('<div class="board"></div>'));
    $("div.board").toggleClass("center");
    $("div.board").css({"width": this.dim * 30 + "px",
                        "height": this.dim * 30 + "px",
                        "margin-left": -this.dim * 30 / 2 + "px",
                        "margin-top": -this.dim * 30 / 2 + "px",});

    return _.times(that.dim, function (i) {
      var $row = $('<div class="row" id="' + i + '"></div>')
      $(".board").append($row);

      return _.times(that.dim, function (j) {
        var $cell = $('<div class="col"></div>');
        var pos = {x: i, y: j};

        if (_.isEqual(that.board.head, pos)) {
          $cell.toggleClass("head");
        } else if (that.board.hasSeg(pos)) {
          $cell.toggleClass("seg");
        } else if (that.board.hasWall(pos)) {
          $cell.toggleClass("wall");
        } else if (that.board.hasApple(pos)) {
          $cell.toggleClass("apple");
        } 

        $(".row#" + i).append($cell);
      });
    });
  }

  Game.prototype.updateBoard = function () {
    var that = this;

    _.times(that.dim, function (i) {
      var $rowCells = $(".row#" + i).children();

      $rowCells.each(function (j, el) {
        var pos = {x: i, y: j};

        if (that.board.hasApple(pos)) {
          el.setAttribute("class", "col apple");
        } else if (that.board.hasWall(pos)) {
          el.setAttribute("class", "col wall");
        } else if (_.isEqual(that.board.head, pos)) {
          el.setAttribute("class", "col head");
        } else if (that.board.hasSeg(pos)) {
          el.setAttribute("class", "col seg");
        } else {
          el.setAttribute("class", "col");
        }
      })
    })
  }

  Game.prototype.makeMove = function (impulse) {
    this.board.moveHead(impulse.x, impulse.y);
  }

  Game.prototype.lose = function () {
    return this.board.lose();
  }

  Game.prototype.won = function () {
    return this.board.won();
  }

  Game.prototype.wonAction = function () {
    var $winMsg = $('<div class="endmsg">You win!</div>');
    $("body").prepend($winMsg);
    clearInterval(this.interval);
  }

  Game.prototype.loseAction = function () {
    var $loseMsg = $('<div class="endmsg">You lose.</div>');
    $("body").prepend($loseMsg);
    clearInterval(this.interval);
  }

  return Game;
})();
