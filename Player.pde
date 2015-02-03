class Player {
  public ArrayList<String> words[];
  public int vocalSize;
  public String freqWords;
  public int r,b,g;
  public String name;
  public PImage nameTagFile;

  public Player(int VS, ArrayList<String> FW, String name, String nameTagFile) {
     this.words = new ArrayList[maxSentences];
     this.vocalSize = VS;
     this.freqWords = "";
     for(String w:FW) this.freqWords += w + " ";
     //this.col = color(50 + random(155), 50 + random(155), 0);
     this.name = name;
     this.nameTagFile = loadImage(nameTagFile);
  }
  
  public void addNextWord(int currentSentence,String w){
     if (words[currentSentence]==null) words[currentSentence] =  new ArrayList<String>();
     words[currentSentence].add(w);
  }  
}
