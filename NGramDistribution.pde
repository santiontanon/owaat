class NGramDistribution extends SequenceDistribution {

    int n = 1;
    int multipliers[] = null;
    int []counts = null;
    
    // to set up n-grams  (n >= 1)
    public NGramDistribution(int[] a_symbols, int a_n) throws Exception {
        super(a_symbols);
        n = a_n;
        if (n<1) throw new Exception("NGramDistribution: n must be >= 1");
        multipliers = new int[n];
        int m = 1;
        for(int i = 0;i<n;i++) {
            multipliers[i] = m;
    //            System.out.println("multipliers[" + i + "] = " + m);
            m*=NSYMBOLS;
        }
        counts = new int[m];
    }
    
    
    public NGramDistribution(int n_symbols, int a_n) throws Exception {
        super(n_symbols);
        n = a_n;
        if (n<1) throw new Exception("NGramDistribution: n must be >= 1");
        multipliers = new int[n];
        int m = 1;
        for(int i = 0;i<n;i++) {
            multipliers[i] = m;
    //            System.out.println("multipliers[" + i + "] = " + m);
            m*=NSYMBOLS;
        }
        counts = new int[m];
    }
    
    
    public void train(int []sequence) {
        int previous[] = new int[n];
        
        for(int symbol:sequence) {
            previous[0] = symbol;
            
            counts[index(previous)]++;
            
            for(int i = n-1;i>0;i--) {
                previous[i] = previous[i-1];
            }
        }        
    }
    
    
    public void train(ArrayList<Integer> sequence) {
        int previous[] = new int[n];
        
        for(int symbol:sequence) {
            previous[0] = symbol;
            
            counts[index(previous)]++;
            
            for(int i = n-1;i>0;i--) {
                previous[i] = previous[i-1];
            }
        }        
    }    
    
    
    public void trainNoDelimiters(ArrayList<Integer> sequence) {
        int previous[] = new int[n];
        
        for(int symbol:sequence) {
            previous[0] = symbol;
            
            if (symbol!=0) {
              counts[index(previous)]++;
              for(int i = n-1;i>0;i--) {
                  previous[i] = previous[i-1];
              }
            } else {
              for(int i = 0;i<n;i++) previous[i] = 0;
            }
        }        
    }        
        
    public void train(String fileName, boolean toLowerCase) throws IOException {
        int previous[] = new int[n];
        
        BufferedReader fr = createReader(fileName);
                
        while(fr.ready()) {
            int tmp = fr.read();
            if (toLowerCase) tmp = Character.toLowerCase(tmp);
            previous[0] = symbolIndex(tmp);
            
            counts[index(previous)]++;
            
            for(int i = n-1;i>0;i--) {
                previous[i] = previous[i-1];
            }
        }        
    }
    
    public int index(int seq[]) {
        int idx = 0;
        for(int i = 0;i<n;i++) {
            idx += multipliers[i]*seq[i];
        }
        return idx;
    }
    
    
    public Integer generateSymbol(int previous[]) throws Exception
    {
        double []distribution = new double[NSYMBOLS];
        double total = 0;
        Sampler s = new Sampler();
        for(int i = 0;i<NSYMBOLS;i++) {
            previous[0] = i;
//            println(n + " " + previous.length);
            distribution[i] = counts[index(previous)];
            total+=distribution[i];
        }
        
        int symbol = s.weighted(distribution);
        if (total>0) return symbol;
        return null;        
    }
    
    
    public Integer generateSymbolAmong(int previous[], ArrayList<Integer> candidates) throws Exception
    {
        double []distribution = new double[NSYMBOLS];
        double total = 0;
        Sampler s = new Sampler();
        for(int i = 0;i<NSYMBOLS;i++) {
            if (candidates.contains(i)) {
              previous[0] = i;
  //            println(n + " " + previous.length);
              distribution[i] = counts[index(previous)];
              total+=distribution[i];
            }
        }
        
        int symbol = s.weighted(distribution);
        if (total>0) return symbol;
        return null;        
    }
    
    
    public ArrayList<Integer> generateSequence(int maxLength, boolean delimitByDelimiters) {
        int maxInitialAttempts = 1000;
        int previous[] = new int[n];
        ArrayList<Integer> sequence = new ArrayList<Integer>();
        double []distribution = new double[NSYMBOLS];
        int last = 0;
        Sampler s = new Sampler();
        
        try {
            do{
                // get the ditribution for the next character:
                for(int i = 0;i<NSYMBOLS;i++) {
                    previous[0] = i;
                    distribution[i] = counts[index(previous)];
                }
    //                System.out.println(Arrays.toString(previous));
    //                System.out.println("    " + Arrays.toString(distribution));
                
                // sample:
                if (delimitByDelimiters && last==0) {
                    do {
                        previous[0] = s.weighted(distribution);
                        maxInitialAttempts--;
                    }while(previous[0]==0 && maxInitialAttempts>0);
                } else {
                    previous[0] = s.weighted(distribution);
                }
                last = previous[0];
    
                // add the new character to the sequence:
                if (delimitByDelimiters) {
                    if (previous[0]!=0) sequence.add(symbols[previous[0]]);
                } else {
                    sequence.add(symbols[previous[0]]);
                }
                if (delimitByDelimiters && previous[0]==0) break;
                for(int i = n-1;i>0;i--) {
                    previous[i] = previous[i-1];
                }
            }while(sequence.size()<maxLength);
        }catch(Exception e) {
            e.printStackTrace();
        }
        
        return sequence;
    }    


    // the following functino assumes n = 1:
    public int getSymbolCount(int symbol) {
        if (n!=1) return 0;
        return counts[symbol];
    }     
    
}
