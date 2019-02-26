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
  margin-top: auto;
  margin-bottom: auto;
  padding-top: 6px;
`;

export const Nav = styled.div`
  font-family: Poppins;
  font-size: 16px;
  color: #222326;
  margin-right: 40px;
  text-transform: uppercase;
  user-select: none;
  cursor: pointer;
`;

export const DropdownGroup = styled.div`
  display: flex;
  justify-content: space-between;
  width: 100%;
  margin-top: auto;
  margin-bottom: auto;
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
