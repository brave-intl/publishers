import styled from 'styled-components'
import { Button, FormField, Box, Anchor } from 'grommet'

// Large primary signup button
export const PrimaryButton = styled(Button)`
  color: #fff;
  background: #fb542b;
  border: #fb542b;
  font-size: 20px;
  padding: 16px 42px;
  min-width: 160px;
  text-align: center;
  &:hover {
    background: #f43405;
    box-shadow: 0 0 0 0 !important;
    transition: all 400ms;
  }
`

export const SecondaryButton = styled(Button)`
  color: #fff;
  background: transparent;
  border: 2px solid #fff;
  text-align: center;
  &:hover {
    background: rgba(255, 255, 255, 0.2);
    box-shadow: 0 0 0 0 !important;
    transition: all 400ms;
  }
`

export const StyledInput = styled(FormField)`
  font-size: 16px;
  width: 100%;
  margin: 0 0 24px;
  & input {
    height: 48px;
    border-radius: 4px;
    background: white;
    font-weight: 400;
  }
  & :focus-within {
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    border-bottom: none !important;
    transition: all 400ms;
  }
`

export const CardButtonContainer = styled(Box)`
  border: 1px solid rgba(255, 255, 255, 0.4);
  padding: 24px;
  border-radius: 8px;
  font-size: 18px;
  &:hover {
    background: rgba(255, 255, 255, 0.2);
  }
`

export const CardButtonAnchor = styled(Anchor)`
  flex-grow: 1;
`
