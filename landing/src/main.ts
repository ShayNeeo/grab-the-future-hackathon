import './style.css'

const app = document.querySelector<HTMLDivElement>('#app')!

app.innerHTML = `
  <!-- Hero -->
  <section class="min-h-screen flex flex-col items-center justify-center px-6 text-center">
    <div class="mb-8">
      <div class="w-28 h-28 mx-auto mb-6 rounded-full bg-teal-600 flex items-center justify-center shadow-2xl shadow-teal-500/30">
        <svg class="w-16 h-16 text-white" fill="currentColor" viewBox="0 0 24 24">
          <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
        </svg>
      </div>
      <h1 class="text-5xl md:text-7xl font-extrabold mb-4 bg-gradient-to-r from-teal-300 to-teal-100 bg-clip-text text-transparent">
        Justful
      </h1>
      <p class="text-xl md:text-2xl text-teal-200 max-w-2xl mx-auto leading-relaxed">
        Bảo vệ bạn khỏi lừa đảo với trí tuệ nhân tạo
      </p>
    </div>
    <p class="text-lg text-teal-300/80 max-w-xl mb-10">
      Ứng dụng AI dành cho người cao tuổi Việt Nam — phát hiện lừa đảo qua tin nhắn, hình ảnh và cuộc gọi một cách tự động.
    </p>
    <div class="flex flex-col sm:flex-row gap-4">
      <a href="#features" class="px-8 py-4 bg-teal-500 hover:bg-teal-400 text-teal-950 font-bold rounded-2xl text-lg transition-all hover:scale-105 shadow-lg shadow-teal-500/25">
        Tìm hiểu thêm
      </a>
      <a href="#download" class="px-8 py-4 border-2 border-teal-500 text-teal-300 hover:bg-teal-500/10 font-bold rounded-2xl text-lg transition-all">
        Tải ứng dụng
      </a>
    </div>
  </section>

  <!-- Features -->
  <section id="features" class="py-24 px-6">
    <div class="max-w-6xl mx-auto">
      <h2 class="text-4xl md:text-5xl font-extrabold text-center mb-4">Tính năng nổi bật</h2>
      <p class="text-teal-300/80 text-center text-lg mb-16 max-w-2xl mx-auto">
        Justful sử dụng AI tiên tiến để bảo vệ bạn và gia đình khỏi các hình thức lừa đảo phổ biến.
      </p>
      <div class="grid md:grid-cols-3 gap-8">
        ${featureCard('shield', 'Phát hiện lừa đảo AI', 'Phân tích tin nhắn, hình ảnh và hợp đồng bằng trí tuệ nhân tạo Gemini.')}
        ${featureCard('mic', 'Nhận diện giọng nói', 'Nói thay vì gõ — trợ lý AI hiểu tiếng Việt tự nhiên.')}
        ${featureCard('family', 'Bảo vệ gia đình', 'Thông báo tự động đến người thân khi phát hiện rủi ro cao.')}
        ${featureCard('phone', 'Chống cuộc gọi rác', 'Tự động cảnh báo cuộc gọi lừa đảo, giả mạo ngân hàng.')}
        ${featureCard('clock', 'Thời gian chờ 48h', 'Hết áp lực phải quyết định ngay — cho bạn thời gian suy nghĩ.')}
        ${featureCard('doc', 'Phân tích hợp đồng', 'Quét điều khoản bất lợi, phạt bất cân xứng trong hợp đồng.')}
      </div>
    </div>
  </section>

  <!-- How it works -->
  <section class="py-24 px-6 bg-teal-900/30">
    <div class="max-w-4xl mx-auto text-center">
      <h2 class="text-4xl md:text-5xl font-extrabold mb-16">Cách sử dụng</h2>
      <div class="grid md:grid-cols-3 gap-12">
        ${stepCard('1', 'Gửi nội dung', 'Chụp ảnh tin nhắn, hợp đồng hoặc mô tả tình huống.')}
        ${stepCard('2', 'AI phân tích', 'Gemini AI kiểm tra dấu hiệu lừa đảo trong vài giây.')}
        ${stepCard('3', 'Nhận cảnh báo', 'Xem mức độ rủi ro và hướng dẫn xử lý cụ thể.')}
      </div>
    </div>
  </section>

  <!-- Download -->
  <section id="download" class="py-24 px-6">
    <div class="max-w-3xl mx-auto text-center">
      <h2 class="text-4xl md:text-5xl font-extrabold mb-6">Tải Justful ngay</h2>
      <p class="text-teal-300/80 text-lg mb-10">
        Miễn phí cho người dùng Android. Yêu cầu Android 7.0+ (arm64).
      </p>
      <a href="https://github.com/ShayNeeo/grab-the-future-hackathon/releases/latest/download/app-arm64-v8a-release.apk"
         class="inline-flex items-center gap-3 px-10 py-5 bg-teal-500 hover:bg-teal-400 text-teal-950 font-extrabold rounded-2xl text-xl transition-all hover:scale-105 shadow-lg shadow-teal-500/25">
        <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3"/>
        </svg>
        Tải APK cho Android
      </a>
      <p class="text-teal-400/60 text-sm mt-6">
        Phiên bản mới nhất • arm64-v8a • ~19MB
      </p>
    </div>
  </section>

  <!-- Footer -->
  <footer class="py-12 px-6 border-t border-teal-800/50">
    <div class="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6 text-teal-400/60 text-sm">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 rounded-full bg-teal-600 flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
          </svg>
        </div>
        <span class="font-bold text-teal-300">Justful</span>
      </div>
      <p>© 2026 Justful. Bảo vệ người cao tuổi Việt Nam.</p>
      <a href="https://github.com/ShayNeeo/grab-the-future-hackathon" class="hover:text-teal-300 transition-colors">
        GitHub
      </a>
    </div>
  </footer>
`

function featureCard(icon: string, title: string, desc: string): string {
  const icons: Record<string, string> = {
    shield: '<path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>',
    mic: '<path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.91-3c-.49 0-.9.36-.98.85C16.52 14.2 14.47 16 12 16s-4.52-1.8-4.93-4.15c-.08-.49-.49-.85-.98-.85-.61 0-1.09.54-1 1.14.49 3 2.89 5.35 5.91 5.78V20c0 .55.45 1 1 1s1-.45 1-1v-2.08c3.02-.43 5.42-2.78 5.91-5.78.1-.6-.39-1.14-1-1.14z"/>',
    family: '<path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>',
    phone: '<path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/>',
    clock: '<path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>',
    doc: '<path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>',
  }
  return `
    <div class="bg-teal-900/40 border border-teal-800/50 rounded-2xl p-8 hover:bg-teal-900/60 transition-all hover:-translate-y-1">
      <div class="w-14 h-14 rounded-xl bg-teal-600/20 flex items-center justify-center mb-5">
        <svg class="w-7 h-7 text-teal-400" fill="currentColor" viewBox="0 0 24 24">${icons[icon] || icons.shield}</svg>
      </div>
      <h3 class="text-xl font-bold mb-2">${title}</h3>
      <p class="text-teal-300/70 leading-relaxed">${desc}</p>
    </div>
  `
}

function stepCard(num: string, title: string, desc: string): string {
  return `
    <div>
      <div class="w-16 h-16 rounded-full bg-teal-600 text-teal-100 text-2xl font-extrabold flex items-center justify-center mx-auto mb-5">
        ${num}
      </div>
      <h3 class="text-xl font-bold mb-2">${title}</h3>
      <p class="text-teal-300/70">${desc}</p>
    </div>
  `
}
