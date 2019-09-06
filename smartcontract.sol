pragma solidity ^0.4.23;
contract supplychain{
    mapping(uint=>address)last_access;
    mapping(uint=>address)next_access;
    mapping(uint=>address)retailer;
    mapping(uint=>bool)sold;
    struct meds {
        string medName;
        address manufacture;
        string manufactureName;
        uint id;
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
    mapping(uint=>Manufacturedetails) md;
    mapping(uint=>retaildetails) rd;
    mapping(uint=>Distdetails) dd;
     mapping (uint => meds) med;
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
     function getmed(uint _id) public  view returns(string medName,
                             string manufactureName,
                             address manufacture) {
        meds memory tmpData = med[_id];
        return (tmpData.medName,tmpData.manufactureName,tmpData.manufacture);
    }  
    function setmed(string _medName,string _manufactureName,uint sid,uint lid,address _to,string _distributorName) public{
        require(manaprove[msg.sender]==true);
        require(distaprove[_to]==true);
        medsData.medName=_medName;
        medsData.manufactureName=_manufactureName;
        medsData.manufacture=msg.sender;
        ManufacturedetailsData.name=_manufactureName;
        ManufacturedetailsData.to=_to;
        ManufacturedetailsData.distributorName=_distributorName;
        ManufacturedetailsData.departureDateTime=now;
        for(uint i=sid;i<=lid;i++){
            
        med[i]= medsData;
        sold[i]=false;
        md[i]=ManufacturedetailsData;
        last_access[i]=msg.sender;
        next_access[i]=_to;
        userDetails[msg.sender].stock[_medName]++;}
        }
    function acceptdist(uint sid,uint lid,address _from)public{
        require(manaprove[_from]==true);
        require(distaprove[msg.sender]==true);
        DistdetailsData.name=userDetails[msg.sender].name;
        DistdetailsData.dist=msg.sender;
               for(uint i=sid;i<=lid;i++){
        require(_from==last_access[i]);
          require(msg.sender==next_access[i]);
          last_access[i]=msg.sender;
          dd[i]=DistdetailsData;
           userDetails[msg.sender].stock[med[i].medName]++;
            userDetails[_from].stock[med[i].medName]--;
        }
       }
    function setdistdetails(address _to,uint sid,uint lid) public {
        require(distaprove[msg.sender]==true);
        require(retailaprove[_to]==true);
               for(uint i=sid;i<=lid;i++){
        require(msg.sender==next_access[i]);
        require(userDetails[msg.sender].stock[med[i].medName]>=1);
        next_access[i]=_to;
               }
    }
    function getdistdetails(uint _id)public view returns(string distname,address d){
        Distdetails memory tmpData=dd[_id];
        return(tmpData.name,tmpData.dist);
    }
    function getmandetails(uint _id)public view returns(string _name,address _to,uint256 time){
        Manufacturedetails memory tmpData=md[_id];
         return(tmpData.name,tmpData.to,tmpData.departureDateTime);
    }
       function setretaildetails(uint _id,string _name,address _dist)public{
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
    function getretaildetails(uint _id) public view returns(string _name,address _dist,address _own){
        retaildetails memory tmpdata=rd[_id];
        return(tmpdata.name,tmpdata.dist,tmpdata.own);
    }
    function sell(uint _id)public{
        require(retailer[_id]==msg.sender);
        require(userDetails[msg.sender].stock[med[_id].medName]>=1);
        require(sold[_id]==false);
        sold[_id]=true;
        userDetails[msg.sender].stock[med[_id].medName]--;
    }
}
