pragma solidity ^0.4.23;
contract supplychain{
    mapping(uint=>address)last_access;
    mapping(uint=>address)next_access;
    mapping(uint=>address)retailer;
    mapping(uint=>bool)sold;
    mapping(uint=>bool)expired;
    struct meds {
        string medName;
        
        uint id;
        uint256 exp;
    }
        struct Manufacturedetails{
        address man;
    
        string name;
    }
    struct retaildetails{
        address own;
        string name;
        
    }
     struct Distdetails{
        address dist;
        string name;
    }
    
    struct user {
        mapping(string=>uint24) stock;
        string role;
        string name;
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
     
     function setuser(string _role,address _user,string name)public {
         if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("Manufacturer")))){
          manaprove[_user]=true;
             }
        if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("Distributer")))){
          distaprove[_user]=true;
             }
        if(uint(keccak256(abi.encodePacked(_role))) == uint(keccak256(abi.encodePacked("Retailer")))){
          retailaprove[_user]=true;
             }
         userData.role=_role;
         userData.name=name;
         userDetails[_user]=userData;
     }
     
     function getmed(uint _id) public  view returns(string medName,
                             
                             address manufacture,string mname,address d,string dname,string rname,bool soldstatus) {
       
        return (med[_id].medName,md[_id].man,md[_id].name,dd[_id].dist,dd[_id].name,rd[_id].name,sold[_id]);
    }  
    function setmed(string _medName,uint sid,uint lid,address _to,uint256 expiryd ) public  returns(int8 st){
       
        if(manaprove[msg.sender]==false){
            return 0;
        }
         
         if(distaprove[_to]==false){
            return 1;
        }
        require(manaprove[msg.sender]==true);
        require(distaprove[_to]==true);
        medsData.medName=_medName;
       medsData.exp=now+expiryd*1 days;
        
       ManufacturedetailsData.man=msg.sender;
        ManufacturedetailsData.name=userDetails[msg.sender].name;
        for(uint i=sid;i<=lid;i++){
         expired[i]=false;   
        med[i]= medsData;
        sold[i]=false;
        md[i]=ManufacturedetailsData;
        last_access[i]=msg.sender;
        next_access[i]=_to;
        userDetails[msg.sender].stock[_medName]++;}
        return 2;
        }
        function checkex(uint id)public view returns(bool res){
            if(now>=med[id].exp){
                
                return true;
            }
            else{
                
                return false;
            }
        }
    function acceptdist(uint sid,uint lid,address _from)public{
        require(manaprove[_from]==true);
        require(distaprove[msg.sender]==true);
        
        DistdetailsData.dist=msg.sender;
        DistdetailsData.name=userDetails[msg.sender].name;
               for(uint i=sid;i<=lid;i++){
        require(_from==last_access[i]);
          require(msg.sender==next_access[i]);
           require(sold[i]==false);
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
         require(sold[i]==false);
        require(userDetails[msg.sender].stock[med[i].medName]>=1);
        next_access[i]=_to;
               }
    }
    
    
       function setretaildetails(uint sid,uint lid,address _dist)public{
        require(retailaprove[msg.sender]==true);
        require(distaprove[_dist]==true);
        for(uint i=sid;i<=lid;i++){
        require(_dist==last_access[i]);
        require(sold[i]==false);
        require(msg.sender==next_access[i]);
        retaildetailsData.own=msg.sender;
        retaildetailsData.name=userDetails[msg.sender].name;
        rd[i]=retaildetailsData;
        retailer[i]=msg.sender;
        userDetails[msg.sender].stock[med[i].medName]++;
            userDetails[_dist].stock[med[i].medName]--;
        }
       }
   
    function sell(uint _id)public{
        require(retailer[_id]==msg.sender);
        require(userDetails[msg.sender].stock[med[_id].medName]>=1);
        require(sold[_id]==false);
        sold[_id]=true;
        userDetails[msg.sender].stock[med[_id].medName]--;
    }
}
