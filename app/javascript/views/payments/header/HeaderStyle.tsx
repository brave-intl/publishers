import styled from "styled-components";

export const Wrapper = styled.div`
  background-color: #a0a1b2;
  margin-top: -2rem;
  margin-bottom: 30px;
  height: 80px;
`;

export const Container = styled.div`
  height: 100%;
  display: flex;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding-left: 30px;
  padding-right: 30px;
`;

export const Navigation = styled.div`
  margin: auto 0 auto 2rem;
  a:not(:last-child) {
    border-right: 1px solid white;
  }
`;

export const HeaderLink = styled.a`
  color: white;
  &:hover {
    color: white;
    text-decoration: none;
  }
`;

interface ILinkProps {
  active?: boolean;
}
export const Link = styled.a`
  font-family: Poppins, sans-serif;
  font-size: 15px;
  color: white;
  padding: 0 1rem 0 1rem;

  &:hover {
    color: white;
  }

  ${(props: ILinkProps) =>
    props.active &&
    `
    text-decoration: underline;
  `}
`;

export const HeaderText = styled.h1`
  font-family: Poppins, sans-serif;
  font-size: 28px;
  color: white;
  padding-top: 4px;
  padding-left: 7px;
  margin-top: auto;
  margin-bottom: auto;
`;
