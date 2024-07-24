import { useEffect } from 'react';
import ProgressRing from '@brave/leo/react/progressRing';
import styles from '@/styles/Toast.module.css';

const Toast = ({ message, onClose }) => {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  return (
    <div className={`${styles['toast']}`}>
      <ProgressRing className={`${styles['toast-progress']}`}/>
      {message}
    </div>
  );
};

export default Toast;