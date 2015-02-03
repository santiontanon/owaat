/*

  Project: "One Word at a Time"
  Description:
    - Project created during the "hackathlon" at the 2015 Dagstuhl seminar on Game AI
    - Provide papers of a given set of authors to train a set of language models of such authors. The
      system then uses the language models to play the "one word at a time" game.
    - The language model consists of two parts:
        - a low-level Markov chain model (2-grams)
        - a high-level grammar represented as a finite state machine to provide structure to the generates sentences.

  Authors:
    Jichen Zhu
    Santiago Ontanon
    Brian Magerko

*/


import rita.*;

// Player configuration:
int playerVoices[] = {0,5,1,2,3,4,0,1,2,1,0,1};
String playerNames[] = {"Ontanon","Zhu","Magerko","Horswill","Young","Buro","Mateas","Cook","Preuss","Treanor","Lucas","Togelius"};
int activePlayers[] = {1,0};
int maxWords = 20;
int maxSentences = 5;

// Internal state variables:
ArrayList<Player> players = new ArrayList<Player>();
int current_word;
int ifpronounce_flag;


void setup() {
  try {  
      initPOSTags();
    
      SentenceGenerator sg[] = new SentenceGenerator[12];
      for(int i = 0;i<playerNames.length;i++) {
        sg[i] = new SentenceGenerator(2);
        sg[i].train(new String[]{"papers/"+playerNames[i]+"1.txt"});
      }
 
      // Game 1: generate a sentence for each player: 
      println("Sentences generated only using the Markov model:");    
      for(int i = 0;i<playerNames.length;i++) {
//      for(int i = 4;i<10;i++) {        // use this line instead to generate a sentence for all the "Michaels"
         println("Player " + i + ": " + sg[i].generateSequence(maxWords));
      }
      println("");
      
      println("Sentences generated only using both the Markov model, and the FSM grammar:");    
      for(int i = 0;i<playerNames.length;i++) {
//      for(int i = 4;i<10;i++) {        // use this line instead to generate a sentence for all the "Michaels"
         println("Player " + i + ": " + sg[i].generateSequenceWithFSM(maxWords));
      }

      
      size(800, 550);
      currentState = 0; 
      current_word = 0;
      ifpronounce_flag = 1;
      
      Player p1 = new Player(sg[0].getNWords(), sg[activePlayers[0]].getMostCommonWordsPOS(3,new String[]{"nn","nns","nnp","nnps"}), playerNames[activePlayers[0]],"nametag.png");
      p1.r = 192;
      p1.g = 64;
      p1.b = 64;
      Player p2 = new Player(sg[1].getNWords(), sg[activePlayers[1]].getMostCommonWordsPOS(3,new String[]{"nn","nns","nnp","nnps"}), playerNames[activePlayers[1]],"nametag_blue.png");
      p2.r = 64;
      p2.g = 64;
      p2.b = 192;
      players.add(p1);
      players.add(p2);  
      
      // generate all the sentences:
      for(int j = 0;j<maxSentences;j++) {
        currentState = 0;
        ArrayList<String> previous = new ArrayList<String>();
        for(int i = 0;i<maxWords;i++) {
            int nextPlayer = i%2;
  
            String []posTags = giveNextWordType();
            if (posTags==null) break;                     
//            println(posTags);
            String nextWord = sg[activePlayers[nextPlayer]].generateNextWordPOS(previous,posTags);
            String wordPOS = getPosTag(nextWord);
            previous.add(nextWord);
            updateState(wordPOS);
            // println(previous);      
            players.get(nextPlayer).addNextWord(j,nextWord); 
        }
      }
      
      RiText.defaultFontSize(28);
      RiText.defaults.showBounds = true;      
      
  }catch(Exception e) {
      e.printStackTrace();
  }
}


void keyPressed() {
  current_word ++;
  ifpronounce_flag = 0;
}


void draw() {
  background(255);

  ArrayList<RiText> words = new ArrayList<RiText>();
  
  // create lines from players:
  RiText.disposeAll();
  {
    boolean done = false;
    int start_x = 50;
    int final_x = width-100;
    int x = start_x;
    int y = 50;
    int lastPlayer = -1;
    String lastWord = null;
    int count = 0;
    String previous_w = null;
    for(int sentence = 0;sentence<maxSentences && !done;sentence++) {
      boolean sentenceDone = false;
      for(int i = 0;!sentenceDone;i++) {
        int playerIdx = 0;
        for(Player p:players) {
          if (count>=current_word) {
            done = sentenceDone = true;
            break;
          }
          if (p.words[sentence].size()<=i) {
            sentenceDone = true;
            break;
          }
          String w =  p.words[sentence].get(i);
          RiText word = new RiText(this, w, x, y);
          x+=word.textWidth()+8;
          word.fill(p.r, p.g, p.b);
          if (x>=final_x) {
            x = start_x;
            y+=32;
          }
          previous_w = w;
          lastWord = w;
          lastPlayer = playerIdx;
          count++;
          playerIdx++;
        }
      }
      // next line:
      x = start_x;
      y+=48;
    }
    if (ifpronounce_flag==0 && lastWord!=null){
        pronounce(lastWord,playerVoices[activePlayers[lastPlayer]]);
        ifpronounce_flag = 1;
    }
  }

  RiText.drawAll();
  
  // draw the player tags:
  int x = 0; 
  for(Player p:players) {
    textSize(25);
    fill(0, 102, 153);
    image(p.nameTagFile, x, height-p.nameTagFile.height/2, p.nameTagFile.width/2, p.nameTagFile.height/2);
    text(p.name, x+20, height-p.nameTagFile.height/4+10);
   
    textSize(18);
    text("Most common words:", x+20, height-p.nameTagFile.height/4+36);
    text((String)p.freqWords, x+20, height-p.nameTagFile.height/4+54);
    x+=width-p.nameTagFile.width/2;
  }
}


String getPosTag(String word) {
  if (word.equals("'s")) return "pos";
  String POS[] = RiTa.getPosTags(word);
  if (POS.length>0) return POS[0];
  return null;
}

