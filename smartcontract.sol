contract supplychain{
    mapping(string=>address)last_access;
    mapping(string=>address)next_access;
    mapping(string=>address)retailer;
    mapping(string=>bool)sold;
    struct meds {
        string medName;
        address manufacture;
        string manufactureName;
        string id;
    }
        struct Manufacturedetails{
        string name;
        address to;
        string distributorName;
        uint256 departureDateTime;
    }
    struct retaildetails{
        string name;
        address dist;
        address own;
        
    }
     struct Distdetails{
        string name;
        address to;
        uint256 departureDateTime;
        address dist;
    }
    
    struct user {
        string name;
        mapping(string=>uint24) stock;
        string contactNo;
        string location;
        string role;
        } 
        mapping(address => user) userDetails;
    user userData;
    mapping(address=>bool) manaprove;
    mapping(address=>bool) distaprove;
    mapping(address=>bool) retailaprove;
    mapping(string=>Manufacturedetails) md;
    mapping(string=>retaildetails) rd;
    mapping(string=>Distdetails) dd;
     mapping (string => meds) med;
     meds medsData;
     retaildetails retaildetailsData;
     Manufacturedetails ManufacturedetailsData;
     Distdetails DistdetailsData;
     function setuser(string _role,address _user,string _name,string _contactNo,string _location)public {
         if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("manufacturer")))){
          manaprove[_user]=true;
             }
        if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("distributor")))){
          distaprove[_user]=true;
             }
        if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("retailer")))){
          retailaprove[_user]=true;
             }
         userData.name=_name;
         userData.contactNo=_contactNo;
         userData.location=_location;
         userData.role=_role;
         userDetails[_user]=userData;
     }
     function getuser(address _user)public view returns(string _name,string _role,string _location,string _contactNo,uint24 stock){
         user memory tmpData=userDetails[_user];
         uint24 a = userDetails[_user].stock["crocin"];
         return(tmpData.name,tmpData.role,tmpData.location,tmpData.contactNo,a);
     }
     function getmed(string _id) public  view returns(string medName,
                             string manufactureName,
                             address manufacture) {
        meds memory tmpData = med[_id];
        return (tmpData.medName,tmpData.manufactureName,tmpData.manufacture);
    }  
    function setmed(string _medName,string _manufactureName,string _id,address _to,string _distributorName) public{
        require(manaprove[msg.sender]==true);
        require(distaprove[_to]==true);
            medsData.medName=_medName;
        medsData.manufactureName=_manufactureName;
        medsData.manufacture=msg.sender;
        med[_id]= medsData;
        sold[_id]=false;
        ManufacturedetailsData.name=_manufactureName;
        ManufacturedetailsData.to=_to;
        ManufacturedetailsData.distributorName=_distributorName;
        ManufacturedetailsData.departureDateTime=now;
        md[_id]=ManufacturedetailsData;
        last_access[_id]=msg.sender;
        next_access[_id]=_to;
        userDetails[msg.sender].stock[_medName]++;
        }
    function acceptdist(string _id,address _from)public{
        require(manaprove[_from]==true);
        require(_from==last_access[_id]);
         require(distaprove[msg.sender]==true);
          require(msg.sender==next_access[_id]);
          last_access[_id]=msg.sender;
           userDetails[msg.sender].stock[med[_id].medName]++;
            userDetails[_from].stock[med[_id].medName]--;
       }
    function setdistdetails(address _to,string _name,string _id) public {
        require(distaprove[msg.sender]==true);
        require(retailaprove[_to]==true);
        require(msg.sender==next_access[_id]);
        require(userDetails[msg.sender].stock[med[_id].medName]>=1);
        DistdetailsData.to=_to;
        DistdetailsData.name=_name;
        DistdetailsData.departureDateTime=now;
        DistdetailsData.dist=msg.sender;
        dd[_id]=DistdetailsData;
        last_access[_id]=msg.sender;
        next_access[_id]=_to;
    }
    function getdistdetails(string _id)public view returns(string distname,address r,uint256 time,address d){
        Distdetails memory tmpData=dd[_id];
        return(tmpData.name,tmpData.to,tmpData.departureDateTime,tmpData.dist);
    }
    function getmandetails(string _id)public view returns(string _name,address _to,string _distributorName,uint256 time){
        Manufacturedetails memory tmpData=md[_id];
         return(tmpData.name,tmpData.to,tmpData.distributorName,tmpData.departureDateTime);
    }
       function setretaildetails(string _id,string _name,address _dist)public{
        require(retailaprove[msg.sender]==true);
        require(distaprove[_dist]==true);
        require(_dist==last_access[_id]);
        require(msg.sender==next_access[_id]);
        retaildetailsData.name=_name;
        retaildetailsData.dist=_dist;
        retaildetailsData.own=msg.sender;
        rd[_id]=retaildetailsData;
        retailer[_id]=msg.sender;
        userDetails[msg.sender].stock[med[_id].medName]++;
            userDetails[_dist].stock[med[_id].medName]--;
       }
    function getretaildetails(string _id) public view returns(string _name,address _dist,address _own){
        retaildetails memory tmpdata=rd[_id];
        return(tmpdata.name,tmpdata.dist,tmpdata.own);
    }
    function sell(string _id)public{
        require(retailer[_id]==msg.sender);
        require(userDetails[msg.sender].stock[med[_id].medName]>=1);
        require(sold[_id]==false);
        sold[_id]=true;
        userDetails[msg.sender].stock[med[_id].medName]--;
    }
}