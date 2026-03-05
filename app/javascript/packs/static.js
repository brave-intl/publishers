// Carousel functionality
let currentSlide = 0;
let autoPlayInterval;
const slideTime = 4000;
const totalSlides = 3;

function showSlide(index) {
  const slides = document.querySelectorAll(".carousel-slide");
  const indicators = document.querySelectorAll(".carousel-indicator");

  // Wrap around
  if (index >= totalSlides) {
    currentSlide = 0;
  } else if (index < 0) {
    currentSlide = totalSlides - 1;
  } else {
    currentSlide = index;
  }

  // Update slides - use display instead of opacity
  slides.forEach((slide, i) => {
    if (i === currentSlide) {
      slide.classList.add("active");
    } else {
      slide.classList.remove("active");
    }
  });

  // Update indicators
  indicators.forEach((indicator, i) => {
    if (i === currentSlide) {
      indicator.classList.add("active");
    } else {
      indicator.classList.remove("active");
    }
  });
}

function changeSlide(direction) {
  stopAutoPlay();
  showSlide(currentSlide + direction);
  startAutoPlay(); // Restart after manual change
}

function goToSlide(index) {
  stopAutoPlay();
  showSlide(index);
  startAutoPlay(); // Restart after manual change
}

function startAutoPlay() {
  stopAutoPlay(); // Clear any existing interval
  autoPlayInterval = setInterval(() => {
    showSlide(currentSlide + 1);
  }, slideTime);
}

function stopAutoPlay() {
  if (autoPlayInterval) {
    clearInterval(autoPlayInterval);
    autoPlayInterval = null;
  }
}

// Initialize on load
document.addEventListener("DOMContentLoaded", function () {
  // Start autoplay
  startAutoPlay();

  // Pause on hover
  const carouselInner = document.querySelector(".carousel-inner");
  const prevBtn = document.querySelector(".carousel-button.prev");
  const nextBtn = document.querySelector(".carousel-button.next");

  if (carouselInner) {
    carouselInner.addEventListener("mouseenter", stopAutoPlay);
    carouselInner.addEventListener("mouseleave", startAutoPlay);
  }

  if (prevBtn) {
    prevBtn.addEventListener("click", () => changeSlide(-1));
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", () => changeSlide(1));
  }
});
