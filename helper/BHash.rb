class BHash

    def initialize(r,s)
        @hash = Hash[r=>s]
        @rhash = Hash[s=>r]
    end

    def findVal(h)
        if @hash.has_key?(h)
            return @hash[h]
        elsif @rhash.has_key?(h)
            return @rhash[h]
        end
        return nil
    end

end
