public class Sampler {

    /*
     * Returns an element in the distribution, using the weights as their relative probabilities
     */
    public int weighted(double []distribution) throws Exception {
        double total = 0, accum = 0, tmp;

        for (double f : distribution) {
            total += f;
        }

        tmp = random(0.0f, (float)total);
        for (int i = 0; i < distribution.length; i++) {
            accum += distribution[i];
            if (accum >= tmp) {
                return i;
            }
        }

        throw new Exception("Input distribution empty in Sampler.weighted (array)!");
    }
    
    
    /*
     * Returns an element in the distribution, using the weights as their relative probabilities
     */
    public int weighted(ArrayList<Double> distribution) throws Exception {
        double total = 0, accum = 0, tmp;

        for (double f : distribution) {
            total += f;
        }

        tmp = random(0,(float)total);
        int i = 0;
        for (double f : distribution) {
            accum += f;
            if (accum >= tmp) {
                return i;
            }
            i++;
        }

        throw new Exception("Input distribution empty in Sampler.weighted (list)!");
    }
}

