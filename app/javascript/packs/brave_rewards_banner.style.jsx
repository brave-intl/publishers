
  let bannerContent = {
    display: 'grid',
    gridTemplateColumns: '3fr 5fr 4fr',
    height: '262px'
  }

  let donationButton = {
    width: '100px',
    textAlign: 'center',
    borderRadius: '20px',
    padding: '11px 10px',
    fontSize: '13px',
    backgroundColor: '#AAAFEF',
    color: 'white',
    float: 'left'
  }

  let socialLinks = {
    backgroundColor: 'rgb(233, 240, 255)',
    paddingTop: '100px',
    paddingLeft:'40px'
  }

  let socialLink = {
    display: 'grid',
    gridTemplateColumns: '1fr 3fr',
    fontSize:'14px',
    height: '25px',
    marginTop: '20px',
    marginBottom: '20px'
  }

  let imageInput = {
    opacity:'0',
    position:'absolute',
  }

  let explanatoryText = {
    backgroundColor: 'rgb(233, 240, 255)',
    paddingRight:'30px'
  }

  let donations = {
    backgroundColor: 'rgb(105, 111, 220)',
    color:'white'
  }

  let batIcon = {
    position:'absolute',
    height:'40px',
    width:'40px',
    right:'0',
    marginTop:'15px',
    marginRight:'80px'
  }

  let bottomBar = {
    display: 'grid',
    gridTemplateColumns: '8fr 4fr',
    height: '50px'
  }

  let donationsCurrent = {
    height:'50px',
    backgroundColor:'#E9E9F4',
    justifyContent:'center',
    fontSize:'13px',
    fontWeight:'600',
    color:'grey',
    textAlign:'center',
    paddingTop:'auto',
    paddingBottom:'auto',
    display:'flex',
    alignItems:'center'
  }

  let donationsSend = {
    height:'50px',
    backgroundColor:'#4C54D2',
    justifyContent:'center',
    fontSize:'13px',
    fontWeight:'600',
    color:'white',
    textAlign:'center',
    paddingTop:'auto',
    paddingBottom:'auto',
    display:'flex',
    alignItems:'center'
  }

  let donationsConverted = {
    fontSize:'13px',
    float:'right',
    paddingTop:'11px',
    marginRight:'80px'
  }

  let donationsButtonContainer = {
    height:'42px',
    marginTop:'10px',
    marginBottom:'10px'
  }


export let styles = {
  bannerContent: bannerContent,
  donationButton: donationButton,
  socialLinks: socialLinks,
  socialLink: socialLink,
  imageInput: imageInput,
  explanatoryText: explanatoryText,
  donations: donations,
  batIcon: batIcon,
  bottomBar: bottomBar,
  donationsCurrent: donationsCurrent,
  donationsSend: donationsSend,
  donationsConverted: donationsConverted,
  donationsButtonContainer: donationsButtonContainer
}
