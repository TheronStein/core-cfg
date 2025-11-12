```php
import { App, Modal } from "obsidian";

export class Example extends Modal {
	constructor(app: App) {
		super(app);
	}
	onOpen() {
		const { contentEl } = this;
		contentEl.empty();

		const wrapper = contentEl.createEl('div', { cls: 'modal-content-wrapper' });

		// Title Input for Task
		const taskTitleLabel = wrapper.createEl('h6', { text: 'Task Title : ' });
		const taskTitleInput = wrapper.createEl('input', { type: 'text', placeholder: 'Enter task title' });
		taskTitleInput.style.marginBottom = '10px';

		const timeWrapper = wrapper.createEl('div', { cls: 'time-input-wrapper' });

		const startTimeWrapper = timeWrapper.createEl('div', { cls: 'start-time-input-wrapper' });
		const startTimeInputTitle = startTimeWrapper.createEl('h6', { text: 'Task Start Time :' });
		const startTimeInput = startTimeWrapper.createEl('input', { type: 'time' });
	}
	
	onClose(): void {
		this.contentEl.empty();
	}
}
```