import { LightningElement, wire } from 'lwc';
import getRecentNews from '@salesforce/apex/RecentNewsController.getRecentNews';

export default class RecentNews extends LightningElement {
    newsList;
    @wire(getRecentNews)
    wiredNews({ error, data }) {
        if (data) {
            this.newsList = data;
        } else if (error) {
            console.error('Error retrieving news:', error);
        }
    }
    handleRedirect(event) {
        const link = event.target.dataset.link;
        window.open(link, '_blank');
    }
}
