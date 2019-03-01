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
  justify-content: space-between;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding-left: 30px;
  padding-right: 30px;
`;

interface INavTextProps {
  header?: boolean;
}
export const Text = styled.div`
  font-family: Poppins, sans-serif;

  ${(props: INavTextProps) =>
    props.header &&
    `
      font-size: 28px;
      color: white;
      padding-top: 4px;
      padding-left: 7px;
      margin-top: auto;
      margin-bottom: auto;
    `}
`;

export const Button = styled.div`
  font-family: Poppins, sans-serif;
  width: 170px;
  color: white;
  text-align: center;
  border-radius: 26px;
  border: 1px solid white;
  margin-top: auto;
  margin-bottom: auto;
  padding: 11px 12px 8px 12px;
  font-size: 15px;
  cursor: pointer;
  user-select: none;
`;
