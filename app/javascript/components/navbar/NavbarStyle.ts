import styled from "styled-components";

interface IModalProps {
  open: boolean;
}

export const Wrapper = styled.div`
  margin-top: -2rem;
  height: 80px;
  background-color: white;
`;

export const Container = styled.div`
  display: flex;
  max-width: 1140px;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
`;

export const Logo = styled.img`
  margin-top: auto;
  margin-bottom: auto;
  padding-right: 160px;
  height: 30px;
`;

export const NavGroup = styled.div`
  display: flex;
`;

interface INavProps {
  selected: boolean;
}
export const Nav = styled.div`
  display: flex;
  align-items: center;
  height: 80px;
  font-family: Poppins;
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

export const DropdownGroup = styled.div`
  display: flex;
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
  top: 80px;
  width: 220px;
  border-radius: 4px;
  box-shadow: 2px 2px 0 0 rgba(47, 48, 50, 0.15);
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
  font-family: Poppins;
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
  font-family: Poppins;
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

export const Name = styled.div`
  padding-top: 6px;
`;

export const DropdownToggle = styled.div`
  padding-top: 4px;
`;
