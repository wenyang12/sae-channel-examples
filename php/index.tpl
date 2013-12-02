<html>
  <head>
      <script src='http://channel.sae.sina.com.cn:9999/api.js'></script>
      <style type='text/css'>
        body {
          font-family: 'Helvetica';
        }

        #board {
          width:152px; 
          height: 152px;
          margin: 20px auto;
        }
        
        #display-area {
          text-align: center;
        }
        
        #this-game {
          font-size: 9pt;
        }
        
        #winner {
        }
        
        table {
          border-collapse: collapse;
        }
        
        td {
          width: 50px;
          height: 50px;
          font-family: "Helvetica";
          font-size: 16pt;
          text-align: center;
          vertical-align: middle;
          margin:0px;
          padding: 0px;
        }
        
        div.cell {
          float: left;
          width: 50px;
          height: 50px;
          border: none;
          margin: 0px;
          padding: 0px;
        }
        
        div.mark {
          position: absolute;
          top: 15px;          
        }
        
        div.l {
          border-right: 1pt solid black;
        }
        
        div.c {
        }
        
        div.r {
          border-left: 1pt solid black;
        }
        
        div.t {
          border-bottom: 1pt solid black;
        }
        
        div.m {
        }
        
        div.b {
          border-top: 1pt solid black;
        }
      </style>
  </head>
  <body>
    <script type='text/javascript'>
      var state = {
        game_key: '<?=$game_key?>',
        me: '<?=$me?>'
      };

      updateGame = function() {
        for (i = 0; i < 9; i++) {
          var square = document.getElementById(i);
          square.innerHTML = state.board[i];
          if (state.winner != '' && state.winningBoard != '') {
            if (state.winningBoard[i] == state.board[i]) {
              if (state.winner == state.me) {
                square.style.background = "green";
              } else {
                square.style.background = "red";
              }
            } else {
              square.style.background = "white";
            }
          }
        }
        
        var display = {
          'other-player': 'none',
          'your-move': 'none',
          'their-move': 'none',
          'you-won': 'none',
          'you-lost': 'none',
          'board': 'block',
          'this-game': 'block',
        }; 

        if (!state.userO || state.userO == '') {
          display['other-player'] = 'block';
          display['board'] = 'none';
          display['this-game'] = 'none';
        } else if (state.winner == state.me) {
          display['you-won'] = 'block';
        } else if (state.winner != '') {
          display['you-lost'] = 'block';
        } else if (isMyMove()) {
          display['your-move'] = 'block';
        } else {
          display['their-move'] = 'block';
        }
        
        for (var label in display) {
          document.getElementById(label).style.display = display[label];
        }
      };
      
      isMyMove = function() {
        return (state.winner == "") && 
            (state.moveX == (state.userX == state.me));
      }

      myPiece = function() {
        return state.userX == state.me ? 'X' : 'O';
      }

      sendMessage = function(path, opt_param) {
        path += '?g=' + state.game_key;
        if (opt_param) {
          path += '&' + opt_param;
        }
        var xhr = new XMLHttpRequest();
        xhr.open('POST', path, true);
        xhr.send();
      };

      moveInSquare = function(id) {
        if (isMyMove() && state.board[id] == ' ') {
          sendMessage('/move', 'i=' + id);
        }
      }

      highlightSquare = function(id) {
        if (state.winner != "") {
          return;
        }
        for (i = 0; i < 9; i++) {
          if (i == id  && isMyMove()) {
            if (state.board[i] = ' ') {
              color = 'lightBlue';
            } else {
              color = 'lightGrey';
            }
          } else {
            color = 'white';
          }

          document.getElementById(i).style['background'] = color;
        }
      }
      
      onOpened = function() {
        sendMessage('/opened');
      };
      
      onMessage = function(m) {
        newState = JSON.parse(m.data);
        state.board = newState.board || state.board;
        state.userX = newState.userX || state.userX;
        state.userO = newState.userO || state.userO;
        state.moveX = newState.moveX;
        state.winner = newState.winner || "";
        state.winningBoard = newState.winningBoard || "";
        updateGame();
      }
      
      openChannel = function() {
        //var token = '<?=$token?>';
        //var uri = 'http://channel.sae.sina.com.cn:9999/' + token;
        //var options = {
        //    debug: true,
        //    protocols_whitelist: [/*'websocket', */'xdr-streaming', 'xhr-streaming', 'iframe-eventsource', 'iframe-htmlfile', 'xdr-polling', 'xhr-polling', 'iframe-xhr-polling', 'jsonp-polling'],
        //};
        var socket = new WebSocket("<?=$token?>");
        socket.onopen = onOpened;
        socket.onmessage = onMessage;
      }
      
      initialize = function() {
        openChannel();
        var i;
        for (i = 0; i < 9; i++) {
          var square = document.getElementById(i);
          square.onmouseover = new Function('highlightSquare(' + i + ')');
          square.onclick = new Function('moveInSquare(' + i + ')');
        }
        onMessage({data: '<?=$initial_message?>'});
      }      

      setTimeout(initialize, 100);

    </script>
    <div id='display-area'>
      <h2>Channel-based Tic Tac Toe</h2>
      <div id='other-player' style='display:none'>
        Waiting for another player to join.<br>
        Send them this link to play:<br>
        <div id='game-link'><a href='<?=$game_link?>'><?=$game_link?></a></div>
      </div>
      <div id='your-move' style='display:none'>
        Your move! Click a square to place your piece.
      </div>
      <div id='their-move' style='display:none'>
        Waiting for other player to move...
      </div>
      <div id='you-won'>
        You won this game!
      </div>
      <div id='you-lost'>
        You lost this game.
      </div>
      <div id='board'>
        <div class='t l cell'><table><tr><td id='0'></td></tr></td></table></div>
        <div class='t c cell'><table><tr><td id='1'></td></tr></td></table></div>
        <div class='t r cell'><table><tr><td id='2'></td></tr></td></table></div>
        <div class='m l cell'><table><tr><td id='3'></td></tr></td></table></div>
        <div class='m c cell'><table><tr><td id='4'></td></tr></td></table></div>
        <div class='m r cell'><table><tr><td id='5'></td></tr></td></table></div>
        <div class='b l cell'><table><tr><td id='6'></td></tr></td></table></div>
        <div class='b c cell'><table><tr><td id='7'></td></tr></td></table></div>
        <div class='b r cell'><table><tr><td id='8'></td></tr></td></table></div>
      </div>
      <div id='this-game' float='top'>
        Quick link to this game: <span id='this-game-link'><a href='<?=$game_link?>'><?=$game_link?></a></span>
      </div>
    </div>
  </body>
</html>
