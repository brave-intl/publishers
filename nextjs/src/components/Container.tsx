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
        'content-background container m-1 rounded transition-colors',
        className,
      )}
    >
      {children}
    </div>
  );
};

export default Container;
