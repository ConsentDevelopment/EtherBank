contract MyEtherBank {

    uint storedData;
    function set(uint x) {
        storedData = x;
    }
    function get() returns (uint retVal) {
        return storedData;
    }


} 