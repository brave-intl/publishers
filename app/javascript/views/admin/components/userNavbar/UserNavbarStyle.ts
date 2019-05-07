import styled from "styled-components";

interface IModalProps {
  open: boolean;
}

export const Wrapper = styled.div`
  height: 80px;
  background-color: white;
  margin-top: -53px;
`;

export const Container = styled.div`
  display: flex;
  justify-content: space-between;
  max-width: 1200px;
  margin: auto;
`;

export const BottomNavContainer = styled.div``;

export const TopNavContainer = styled.div`
  @media (max-width: 1200px) {
    visibility: hidden;
  }
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 28px;
`;

export const Section = styled.div`
  display: flex;
  margin-top: auto;
  margin-bottom: auto;
`;

export const Logo = styled.img`
  margin-top: auto;
  margin-bottom: auto;
  padding-right: 112px;
  cursor: pointer;
  @media (max-width: 1100px) {
    padding-right: 0px;
  }
  height: 30px;
`;

export const NavGroup = styled.div`
  display: flex;
  @media (max-width: 1100px) {
    display: none;
  }
`;

interface INavProps {
  selected: boolean;
}
export const Nav = styled.div`
  display: flex;
  align-items: center;
  height: 80px;
  font-family: Poppins, sans-serif;
  font-size: 16px;
  padding-top: 6px;
  color: #222326;
  margin-right: 40px;
  text-transform: uppercase;
  user-select: none;
  cursor: pointer;

  ${(props: Partial<INavProps>) =>
    props.selected === true &&
    `
    padding-top: 8px;
    border-bottom: 2px solid #4c54d2;
  `}
`;

export const Name = styled.div`
  display: flex;
  align-items: center;
  height: 80px;
  font-size: 30px;
  color: #222326;
  margin-left: 20px;
  user-select: none;
`;

export const Status = styled.div`
  border-radius: 6px;
  background-color: #2dbd4e;
  color: white;
  display: flex;
  align-items: center;
  height: 20px;
  padding: 15px;
  font-size: 16px;
  margin-left: 20px;
  user-select: none;
  margin-top: auto;
  margin-bottom: auto;
`;

export const Avatar = styled.div`
  border-radius: 50%;
  width: 75px;
  height: 75px;
  background-color: #e8e8e8;
`;

export const DropdownGroup = styled.div`
  display: flex;
  position: relative;
  margin-top: auto;
  margin-bottom: auto;
  margin-left: auto;
  user-select: none;
  cursor: pointer;
`;

interface IDropdownMenuProps {
  open: boolean;
}
export const DropdownMenu = styled.div`
  position: absolute;
  background-color: white;
  top: 50px;
  right: 0px;
  width: 220px;
  border-radius: 4px;
  box-shadow: 0px 1px 2px 1px rgba(47, 48, 50, 0.15);
  z-index: 1;
  ${(props: Partial<IDropdownMenuProps>) =>
    props.open === false &&
    `
      visibility: hidden;
  `}
`;

export const DropdownItem = styled.div`
  display: block;
  padding: 20px;
  font-family: Poppins, sans-serif;
  font-size: 16px;
  text-align: center;
  border-top: solid 1px #e7ebee;
  margin: auto;
  &:hover {
    color: #00bcd6;
  }
`;

export const DropdownHeader = styled.div`
  display: block;
  padding: 20px;
  font-family: Poppins, sans-serif;
  font-size: 16px;
  text-align: center;
  border-top: solid 1px #e7ebee;
  margin: auto;
`;

export const AvatarContainer = styled.div`
  width: 36px;
  height: 36px;
  border: solid 1px #d3d5d7;
  border-radius: 18px;
  overflow: hidden;
  margin-right: 8px;
`;

export const DropdownToggle = styled.div`
  padding-top: 4px;
`;
