import rita.*;

class SentenceGenerator {
    
    int order = 2;
    int nextCode = 0;
    HashMap<String,Integer> words = new HashMap<String,Integer>();
    ArrayList<String> wordArray = new ArrayList<String>();
    NGramDistribution distribution = null;
    NGramDistribution baseDistribution = null;
    
    public SentenceGenerator(int a_order) {
        order = a_order;
    }
    
    public int getNWords() {
        return nextCode;
    }
    
    
    public String getMostCommonWord() {
        int maxCode = -1;
        int maxCount = 0;
        for(int code = 0;code<nextCode;code++) {
            int count = baseDistribution.getSymbolCount(code);
            if (maxCode==-1 || count>maxCount) {
                maxCode = code;
                maxCount = count;
            }          
        }
        return wordArray.get(maxCode);
    }
    
    
    public ArrayList<String> getMostCommonWords(int n) {
        int codes[] = new int[nextCode];
        for(int i = 0;i<nextCode;i++) codes[i] = i;
        boolean change = true;
        while(change) {
            change = false;
            for(int i = 0;i<nextCode-1;i++) {
                if (baseDistribution.getSymbolCount(codes[i]) < baseDistribution.getSymbolCount(codes[i+1])) {
                    int tmp = codes[i];
                    codes[i] = codes[i+1];
                    codes[i+1] = tmp;
                    change = true;
                } 
            }
        }
        ArrayList<String> l = new ArrayList<String>();
        for(int i = 0;i<n;i++) {
          l.add(wordArray.get(codes[i]));
        }
        return l;
    }
    
    
    public ArrayList<Integer> getWordsWithPOS(String POSarray[]) {
        ArrayList<Integer> codes = new ArrayList<Integer>();
        for(int i = 0;i<nextCode;i++) {
            String wordPOS = getPosTag(wordArray.get(i));
            if (wordPOS!=null) {
              for(String POS:POSarray) {
                if (wordPOS.equals(POS)) {
                  codes.add(i);
                  break;
                }
              }
            }
        }
        
//        print("getWordsWithPOS: ");
//        println(POSarray);
//        println(codes);
        
        return codes;
    }
    
    public ArrayList<String> getMostCommonWordsPOS(int n, String POS[]) {
        ArrayList<Integer> codes = getWordsWithPOS(POS);

        boolean change = true;
        while(change) {
            change = false;
            for(int i = 0;i<codes.size()-1;i++) {
                if (baseDistribution.getSymbolCount(codes.get(i)) < baseDistribution.getSymbolCount(codes.get(i+1))) {
                    int tmp = codes.get(i);
                    codes.set(i, codes.get(i+1));
                    codes.set(i+1, tmp);
                    change = true;
                } 
            }
        }
        ArrayList<String> l = new ArrayList<String>();
        for(int i = 0;i<n;i++) {
          l.add(wordArray.get(codes.get(i)));
        }
        return l;
    }    
    
        
    public int wordCode(String word) {
        Integer code = words.get(word);
        if (code==null) {
            words.put(word,nextCode);
            wordArray.add(word);
            code = nextCode;
            nextCode++;
        }
        return code;
    }
    
    
    public String generateSequence(int length) {
        ArrayList<Integer> s = distribution.generateSequence(length);
        String sentence = "";
        for(Integer code:s) {
            sentence += wordArray.get(code);
            sentence+=" ";
        }
        return sentence;
    }
    

    public String generateSequenceWithFSM(int length) throws Exception {
      String sentence = null;
      ArrayList<String> previous = new ArrayList<String>();
      currentState = 0;
      for(int i = 0;i<length;i++) {  
          String []posTags = giveNextWordType();
          if (posTags==null) break;
          
          String nextWord = generateNextWordPOS(previous,posTags);
            String wordPOS = getPosTag(nextWord);
            previous.add(nextWord);
            updateState(wordPOS);
            if (sentence==null) sentence = nextWord;
                           else sentence = sentence + " " + nextWord;
        }
            
        return sentence;
    }

    
    public String generateNextWord(ArrayList<String> previousWords) throws Exception {
        int previous[] = new int[order];
        for(int i = 1;i<order;i++) {
            int idx = previousWords.size() - i;
            Integer code = 0;
            if (idx>=0) code = words.get(previousWords.get(idx));
            if (code==null) {
                previous[i] = 0;
            } else {
                previous[i] = code;
            }  
        }
        
        Integer code = distribution.generateSymbol(previous);
        if (code==null) {
          code = baseDistribution.generateSymbol(previous);
        }
        return wordArray.get(code);
    }
    
    
    public String generateNextWordPOS(ArrayList<String> previousWords, String POS[]) throws Exception {
        ArrayList<Integer> codes = getWordsWithPOS(POS);  
        int previous[] = new int[order];
        for(int i = 1;i<order;i++) {
            int idx = previousWords.size() - i;
            Integer code = 0;
            if (idx>=0) code = words.get(previousWords.get(idx));
            if (code==null) {
                previous[i] = 0;
            } else {
                previous[i] = code;
            }  
        }
        
        Integer code = distribution.generateSymbolAmong(previous, codes);
        if (code==null) {
            code = baseDistribution.generateSymbolAmong(previous, codes);
//            println("resorting to base");
        }
        return wordArray.get(code);
    }    
    
    
    public void train(String fileName) throws Exception {
      train(new String []{fileName});
    }
  
  
    public void train(String fileNames[]) throws Exception {
        ArrayList<Integer> sequence = new ArrayList<Integer>();
        String allowedCharacters = "aáàǎāäbcdeéèěēëfghiíìǐīïjklmnñń​oóòǒōöpqrstuúùǔūüǚǜvwxyz'";
        String sentenceSeparators = ".:";
        String currentWord = null;
  
        // insert delimiter:
        wordCode("");
        wordCode("'s");

        for(String fileName:fileNames) {        
          BufferedReader br = createReader(fileName);
          while(br.ready()) {
              int c = br.read();
              c = Character.toLowerCase(c);
              if (c=='’') c = '\'';
              int idx = allowedCharacters.indexOf(c);
              if (idx==-1) {
                  if (currentWord!=null) {
//                      println(currentWord);
                      if (currentWord.endsWith("'s")) {
//                        println("possessive!");
                        currentWord = currentWord.substring(0,currentWord.length()-2);
                        int wordIdx = wordCode(currentWord);
                        int wordIdx2 = wordCode("'s");
                        currentWord = null;
                        sequence.add(wordIdx);
                        sequence.add(wordIdx2);
                      } else {
                        int wordIdx = wordCode(currentWord);
                        currentWord = null;
                        sequence.add(wordIdx);
                      }
                  } 
                  int idx2 = sentenceSeparators.indexOf(c);
                  if (idx2!=-1 && !sequence.isEmpty() && !(sequence.get(sequence.size()-1)==0)) sequence.add(0);  // sentence separator
              } else {
                  if (currentWord==null) currentWord = "";
                  currentWord += (char)c;
              }
          }
          if (currentWord!=null) {
              if (currentWord.endsWith("'s")) {
                currentWord = currentWord.substring(0,currentWord.length()-2);
                int wordIdx = wordCode(currentWord);
                int wordIdx2 = wordCode("'s");
                currentWord = null;
                sequence.add(wordIdx);
                sequence.add(wordIdx2);
              } else {
                int wordIdx = wordCode(currentWord);
                currentWord = null;
                sequence.add(wordIdx);
              }
          }
          
        }
        distribution = new NGramDistribution(words.size(),order);
        baseDistribution = new NGramDistribution(words.size(),1);
        distribution.trainNoDelimiters(sequence);
        baseDistribution.trainNoDelimiters(sequence);
//        println(sequence);
    }
}
