import clsx from 'clsx';
import { FC } from 'react';

type Props = {
  children: React.ReactNode;
  className?: string;
};

const Container: FC<Props> = ({ children, className }) => {
  return (
    <div
      className={clsx(
        'container content-background rounded p-4 m-1 transition-colors',
        className,
      )}
    >
      {children}
    </div>
  );
};

export default Container;
