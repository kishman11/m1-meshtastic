/*
 * m1app_additions.h — declarations to add to the app SDK (m1app.h) so other
 * apps can use the header UART + extended button poll this port adds to the
 * firmware. Paste into bedge117/m1-sdk/include/m1app.h (e.g. after the Virtual
 * Keyboard block). The m1-meshtastic app vendors these itself, so this is
 * only for future apps.
 */

/* ==================================================================
 *  Header UART (USART1: pin 12 = PA9 TX, pin 13 = PA10 RX)
 * ================================================================== */

/* Claim the header UART at `baud`; holds off the USB-serial bridge. Requires
 * the default VCP CDC mode. */
extern void m1_uart_app_init(uint32_t baud);
extern void m1_uart_app_deinit(void);
/* Non-blocking: reads up to max_len buffered bytes, returns the count. */
extern int  m1_uart_app_read(uint8_t *buf, int max_len);
/* Blocking, bounded-timeout transmit to the radio. */
extern void m1_uart_app_write(const uint8_t *buf, int len);
extern int  m1_uart_app_available(void);

/* ==================================================================
 *  Extended button poll (adds long/double click over game_poll_button)
 * ================================================================== */
#define M1_BTN_EVT_NONE   0
#define M1_BTN_EVT_CLICK  1
#define M1_BTN_EVT_DBL    2
#define M1_BTN_EVT_LONG   3
/* Returns an m1app_button_t; *out_evt gets one of M1_BTN_EVT_*. */
extern m1app_button_t m1_poll_button_ex(uint32_t timeout_ms, uint8_t *out_evt);
