'use client';

import { useState, useEffect } from 'react';
import Icon from '@brave/leo/react/icon';

export default function Carousel({ items, slideTime }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [autoPlay, setAutoPlay] = useState(true);

  useEffect(() => {
    if (!autoPlay) return;

    const interval = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % items.length);
    }, slideTime);

    return () => clearInterval(interval);
  }, [autoPlay, items.length]);

  const goToPrevious = () => {
    setAutoPlay(false);
    setCurrentIndex((prevIndex) =>
      prevIndex === 0 ? items.length - 1 : prevIndex - 1,
    );
  };

  const goToNext = () => {
    setAutoPlay(false);
    setCurrentIndex((prevIndex) => (prevIndex + 1) % items.length);
  };

  const handleMouseEnter = () => {
    setAutoPlay(false);
  };

  const handleMouseLeave = () => {
    setAutoPlay(true);
  };

  if (!items || items.length === 0) {
    return <div>No items to display</div>;
  }

  return (
    <div
      className='relative mx-auto w-full max-w-[1200px]'
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      {/* Carousel Container */}
      <div className='bg-gray-100 rounded-lg relative overflow-hidden'>
        {/* Items */}
        <div className='relative h-[500px] w-full'>
          {items.map((item, index) => (
            <div
              key={index}
              className={`absolute inset-0 transition-opacity duration-500 ${
                index === currentIndex ? 'opacity-100' : 'opacity-0'
              }`}
            >
              {item}
            </div>
          ))}
        </div>

        {/* Previous Arrow */}
        <button
          onClick={goToPrevious}
          className='absolute left-1 top-1/2 z-10 transform rounded-full bg-[#5E6175] p-[1px] text-white transition-all hover:bg-opacity-75'
          aria-label='Previous slide'
        >
          <Icon name='carat-left' />
        </button>

        {/* Next Arrow */}
        <button
          onClick={goToNext}
          className='absolute right-1 top-1/2 z-10 transform rounded-full bg-[#5E6175] p-[1px] text-white transition-all hover:bg-opacity-75'
          aria-label='Next slide'
        >
          <Icon name='carat-right' />
        </button>
      </div>

      {/* Indicators */}
      <div className='flex justify-center gap-2'>
        {items.map((_, index) => (
          <button
            key={index}
            onClick={() => {
              setAutoPlay(false);
              setCurrentIndex(index);
            }}
            className={`h-[2px] w-[20px] transition-all ${
              index === currentIndex ? 'bg-[#7d4cdb]' : 'bg-[#666666]'
            }`}
            aria-label={`Go to slide ${index + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
