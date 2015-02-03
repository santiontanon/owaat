HashMap<String,String[]> POStagMap = new HashMap<String,String[]>(); 
HashMap<String,String> POStagBackMap = new HashMap<String,String>();

int currentState = 0;
String states[][] = {{""},    // 0
                     {"dt"},  // 1
                     {"nn"},
                     {"rb"},
                     {"cc"},
                     {"jj"},  // 5
                     {"in"},
                     {"nn"},
                     {"dt"},
                     {"vb"},
                     {"dt"},  // 10
                     {"in"},
                     {"jj"},
                     {"prp"},
                     {"nn"},
                     {"pos"},  // 15
                     {"pos"}};  
int edges[][] = {{0,1,2,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0},    // 0
                 {0,0,0,3,0,5,0,0,0,0, 0, 0, 0, 0, 0, 0, 0},    // 1
                 {0,0,0,0,0,0,6,0,0,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,5,0,0,0,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,3,0,5,0,0,0,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,0,0,7,0,0, 0, 0, 0, 0, 0, 0, 0},    // 5
                 {0,0,0,0,0,0,0,0,8,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,0,6,0,0,9, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,5,0,7,0,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,0,0,0,0,0,10,11, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,0,0,0,0,0, 0, 0,12, 0,14, 0, 0},    // 10
                 {0,0,0,0,0,0,0,0,0,0,10, 0, 0,13, 0, 0, 0},
                 {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0,14, 0, 0},
                 {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0},
                 {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0,15,16},
                 {0,0,0,0,0,0,0,0,0,0, 0, 0,12, 0, 0, 0, 0},    // 15
                 {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0}};  

void initPOSTags() {
  POStagMap.put("cc",new String[]{"cc"});
  POStagMap.put("dt",new String[]{"dt","pdt"});
  POStagMap.put("ex",new String[]{"ex"});
  POStagMap.put("in",new String[]{"in"});
  POStagMap.put("jj",new String[]{"jj","jjr","jjs"});
  POStagMap.put("nn",new String[]{"nn","nns","nnp","nnps"});
  POStagMap.put("pos",new String[]{"pos"});
  POStagMap.put("prp",new String[]{"prp","prps"});  
  POStagMap.put("rb",new String[]{"rb","rbr","rbs"});
  POStagMap.put("vb",new String[]{"vb","vbd","vbg","vbn","vbp","vbz"});
  for(String tmp1:POStagMap.keySet()) {
    for(String tmp2:POStagMap.get(tmp1)) {
      POStagBackMap.put(tmp2,tmp1);
    }
  }
}

/* what is the set of next possible word types given the input set of words? */
String[] giveNextWordType(){
    ArrayList<String> possibleTags = new ArrayList<String>();
    for(int i = 0;i<edges[currentState].length;i++) {
      if (edges[currentState][i]!=0) {
        for(String tag:states[i]) possibleTags.add(tag);
      }
    }   
    if (possibleTags.isEmpty()) return null;
    String []tags = new String[possibleTags.size()];
    for(int i = 0;i<tags.length;i++) tags[i] = possibleTags.get(i);
    String []extendedPosTags = extendPosTags(tags);
    return extendedPosTags;
}


// call this to update the current state in the FSM every time a word type is selected by the generator
//void updateState(String s){
//  currentState = s;
//}

void updateState(String s) {
    String generalizedS = POStagBackMap.get(s);
    ArrayList<Integer> possibleStates = new ArrayList<Integer>();
    for(int i = 0;i<edges[currentState].length;i++) {
      if (edges[currentState][i]!=0) {
        for(String tag:states[i]) {
          if (generalizedS.equals(tag)) {
            possibleStates.add(i);
          }
        }
      }
    }   
    if (!possibleStates.isEmpty()) {
      currentState = possibleStates.get((int)random(0,possibleStates.size()));
    } else {
      println("ERROR!!!! updateState: " + currentState + " " + s + "(" + generalizedS + ")");
    }
}


String []extendPosTags(String POSlist[]) {
  ArrayList<String> l = new ArrayList<String>();
  
  for(String POS:POSlist) {
    for(String tmp:POStagMap.get(POS)) {
      l.add(tmp);
    }
  }
  
  String out[] = new String[l.size()];
  for(int i = 0;i<out.length;i++) out[i] = l.get(i);
  
  return out;
}

